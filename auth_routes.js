const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const mysql = require("mysql2");
const app = express();
const secretKey = "your_secret_key";
app.use(express.json());


// Database connection
const db = mysql.createConnection({
  host: "127.0.0.1",
  user: "root",
  password: "", // Replace with your password
  database: "graduatedbooking",
});

db.connect((err) => {
  if (err) throw err;
  console.log("Connected to the database.");
});

// Middleware to authorize token
function authenticateToken(req, res, next) {
  const token = req.headers["authorization"]?.split(" ")[1];
  if (!token) return res.status(401).json({ message: "Access Denied" });

  jwt.verify(token, secretKey, (err, user) => {
    if (err) return res.status(403).json({ message: "Invalid Token" });
    req.user = user;
    next();
  });
}

// Middleware to authorize roles
function authorizeRoles(allowedRoles) {
  return (req, res, next) => {
    console.log('User Role:', req.user.role); // Debugging line
    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ message: "Access Forbidden" });
    }
    next();
  };
}

// Login endpoint
app.post("/login", (req, res) => {
  const { identifier, password } = req.body; // Accepts either email or username as 'identifier'

  // Query to check both email and username
  db.query(
    "SELECT * FROM users WHERE email = ? OR username = ?",
    [identifier, identifier], // Use 'identifier' for both email and username
    (err, results) => {
      if (err) return res.status(500).json({ message: "Database error" });

      if (results.length === 0)
        return res.status(404).json({ message: "User not found" });

      const user = results[0];
      const isPasswordValid = bcrypt.compareSync(password, user.password);
      if (!isPasswordValid)
        return res.status(401).json({ message: "Invalid credentials" });

      const token = jwt.sign({ userId: user.user_id, role: user.role }, secretKey, {
        expiresIn: "1h",
      });

      res.json({ token, userId: user.user_id, role: user.role });
    }
  );
});

// Register endpoint
app.post("/register", (req, res) => {
  const { username, email, password, phone_number, role } = req.body;

  // Validation: Check for empty fields
  if (!username || !email || !password || !phone_number) {
    return res.status(400).json({ message: "All fields are required" });
  }

  // Validation: Ensure the email ends with @siswa.unimas.my
  const emailRegex = /^[a-zA-Z0-9._%+-]+@siswa\.unimas\.my$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({ message: "Invalid email domain" });
  }

  // Validation: Check phone number format (basic example, customize as needed)
  const phoneRegex = /^[0-9]{10,15}$/; // Example: Allow 10-15 digits
  if (!phoneRegex.test(phone_number)) {
    return res.status(400).json({ message: "Invalid phone number" });
  }

  db.query("SELECT * FROM users WHERE username = ? OR email = ?", [username, email], (err, results) => {
    if (err) return res.status(500).json({ message: "Database error" });

    if (results.length > 0) return res.status(400).json({ message: "Username or Email alreadytaken"});

    const hashedPassword = bcrypt.hashSync(password, 10);
    db.query(
      "INSERT INTO users (username, email, password, phone_number, role) VALUES (?, ?, ?, ?, ?)",
      [username, email, hashedPassword, phone_number, role || "user"],
      (err) => {
        if (err) return res.status(500).json({ message: "Error registering user" });

        res.status(201).json({ message: "User registered successfully" });
      }
    );
  });
});

// Route to get user details by userId
app.get('/api/user/:userId', authenticateToken, (req, res) => {
  const { userId } = req.params;

  db.query('SELECT username, password, phone_number FROM users WHERE user_id = ?', [userId], (err, results) => {
    if (err) {
      console.error('Error fetching user details:', err);
      return res.status(500).json({ message: 'Error fetching user details.' });
    }

    if (results.length > 0) {
      const { username, password, phone_number } = results[0];
      res.status(200).json(results[0]);
    } else {
      res.status(404).json({ message: 'User not found.' });
    }
  });
});

// API to update username and password
app.put('/api/update-user/:id', authenticateToken, async (req, res) => {
  const { id } = req.params; // User ID from URL
  const { username, password } = req.body; // New username and password

  if (!username || !password) {
    return res.status(400).json({ message: 'Username and password are required.' });
  }

  try {
    // Hash the new password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Update the user in the database
    const query = 'UPDATE users SET username = ?, password = ? WHERE user_id = ?';
    db.query(query, [username, hashedPassword, id], (err, results) => {
      if (err) {
        console.error('Error updating user:', err);
        return res.status(500).json({ message: 'Error updating user.' });
      }

      if (results.affectedRows === 0) {
        return res.status(404).json({ message: 'User not found.' });
      }

      res.status(200).json({ message: 'User updated successfully.' });
    });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

// Add bookings to the server
app.post('/api/bookings', authenticateToken, (req, res) => {
  const { userId } = req.user; // Retrieve user_id from decoded token
  const { robe_id, booking_date, price} = req.body;

  if (!robe_id || !booking_date) {
    return res.status(400).json({ error: 'All fields are required for booking' });
  }

  // Check if the booking_date is not in the past
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const selectedDate = new Date(booking_date);

  if (selectedDate < today) {
    return res.status(400).json({ error: 'Booking date cannot be in the past' });
  }

  db.query(
    'SELECT * FROM bookings WHERE user_id = ?',
    [userId],
    (err, existingBooking) => {
      if (err) {
        console.error('Error:', err);
        return res.status(500).json({ message: 'Error checking existing booking.' });
      }

      if (existingBooking.length > 0) {
        return res.status(400).json({ error: 'Booking already exists' });
      }

      db.query(
        'INSERT INTO bookings (user_id, robe_id, booking_date, status, collection_status) VALUES (?, ?, ?, "Active", "Ongoing")',
        [userId, robe_id, booking_date],
        (error) => {
          if (error) {
            console.error('Error:', error);
            return res.status(500).json({ message: 'Internal server error.' });
          }

          res.status(201).json({ message: 'Booking successful' });
        }
      );

      db.query(
        'UPDATE users SET outstanding_payment = outstanding_payment + ? WHERE user_id = ?',
        [price, userId]
   );
});
});

// Latest Booking endpoint
app.get('/api/latest-booking/:userId', (req, res) => {
  const userId = req.params.userId;

  // Get current year, month, and day
  const currentYear = new Date().getFullYear();
  const currentMonth = new Date().getMonth() + 1; // Months are zero-based in JavaScript
  const currentDay = new Date().getDate();

  // SQL query to fetch the latest booking with year, month, and day filtering
  const query = `
    SELECT 
      bookings.booking_id AS booking_id,
      bookings.user_id,
      DATE_FORMAT(bookings.booking_date,'%Y-%m-%d') AS booking_date,
      bookings.collection_status AS booking_status,
      robes.robe_id AS robe_id,
      robes.type AS robe_type,
      robes.size,
      robes.status AS robe_status,
      robes.image_url
    FROM bookings
    INNER JOIN robes ON bookings.robe_id = robes.robe_id
    WHERE bookings.user_id = ?
    ORDER BY bookings.booking_date DESC
    LIMIT 1
  `;

  db.query(query, [userId], (err, results) => {
    if (err) {
      return res.status(500).json({ message: 'Database error', error: err });
    }

    if (results.length === 0) {
      return res.status(404).json({ message: 'No bookings found' });
    }

    res.status(200).json(results[0]);
  });
});

// Route for counting robes
app.get('/count_robe', (req, res) => {

  const countsQuery = `
    SELECT 
        COUNT(CASE WHEN type = 'Bachelor Robe' AND size = 'XS' THEN 1 END) AS BachelorRobe_XS,
        COUNT(CASE WHEN type = 'Bachelor Robe' AND size = 'S' THEN 1 END) AS BachelorRobe_S,
        COUNT(CASE WHEN type = 'Bachelor Robe' AND size = 'M' THEN 1 END) AS BachelorRobe_M,
        COUNT(CASE WHEN type = 'Bachelor Robe' AND size = 'L' THEN 1 END) AS BachelorRobe_L,
        COUNT(CASE WHEN type = 'PhD Robe' AND size = 'XS' THEN 1 END) AS PhDRobe_XS,
        COUNT(CASE WHEN type = 'PhD Robe' AND size = 'S' THEN 1 END) AS PhDRobe_S,
        COUNT(CASE WHEN type = 'PhD Robe' AND size = 'M' THEN 1 END) AS PhDRobe_M,
        COUNT(CASE WHEN type = 'PhD Robe' AND size = 'L' THEN 1 END) AS PhDRobe_L,
        COUNT(CASE WHEN type = 'Master Robe' AND size = 'XS' THEN 1 END) AS MasterRobe_XS,
        COUNT(CASE WHEN type = 'Master Robe' AND size = 'S' THEN 1 END) AS MasterRobe_S,
        COUNT(CASE WHEN type = 'Master Robe' AND size = 'M' THEN 1 END) AS MasterRobe_M,
        COUNT(CASE WHEN type = 'Master Robe' AND size = 'L' THEN 1 END) AS MasterRobe_L
    FROM robes;
  `;

  // Execute the query
  db.query(countsQuery, (err, results) => {
    if (err) {
      console.error('Error fetching data:', err.message);
      res.status(500).send('Error fetching data');
      return;
    }
    res.status(200).json(results);
  });
});

// API endpoint to get robes_status
app.get('/robes_status', (req, res) => {
  const query = 'SELECT * FROM robes_status';
  db.query(query, (err, results) => {
    if (err) {
      console.error('Error fetching data:', err.message);
      res.status(500).send('Error fetching data');
      return;
    }
    res.status(200).json(results);
  });
});

// Get All Robes
app.get('/getRobes', authenticateToken, (req, res) => {
  const query = 'SELECT * FROM robes';

  db.query(query, (err, results) => {
    if (err) {
      console.error('Error fetching robes:', err);
      res.status(500).json({ error: 'Internal server error' });
    } else {
      res.status(200).json(results);
    }
  });
});

// Route to fetch robes based on size
app.get('/robes', async (req, res) => {
  const { size } = req.query; // Get size from query parameters

  if (!size) {
    return res.status(400).json({ message: 'Size parameter is required.' });
  }

  try {
    const query = 'SELECT * FROM robes_status WHERE size = ?';
    db.query(query, [size], (err, results) => {
      if (err) {
        console.error('Error fetching robes:', err);
        return res.status(500).json({ message: 'Error fetching robes.' });
      }

      res.status(200).json(results);
    });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'Internal server error.'});
  }
});

app.get('/api/outstanding-payment/:user_id', (req, res, next) => {
  const { user_id } = req.params;

  db.query(
      `
      SELECT SUM(r.price) AS total_outstanding
      FROM bookings b
      JOIN robes r ON b.robe_id = r.robe_id
      WHERE b.user_id = ? AND b.booking_date >= CURDATE()
      `,
      [user_id],
      (error, results) => {
          if (error) {
              return next(error);  // Forward the error to the error-handling middleware
          }

          const totalOutstanding = results[0]?.total_outstanding || 0;
          res.status(200).json({ outstanding_payment: totalOutstanding });
      }
    );
  });

// Admin route
app.get("/admin", [authenticateToken, authorizeRoles(["admin"])], (req, res) => {
  res.json({ message: "Welcome Admin!" });
});

// User route
app.get("/user", [authenticateToken, authorizeRoles(["user", "admin"])], (req, res) => {
  res.json({ message: "Welcome User!" });
});

// Start server
app.listen(6000, '0.0.0.0', () => {
  console.log("Server running on port 6000");
});
