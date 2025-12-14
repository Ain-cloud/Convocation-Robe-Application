const express = require('express');
const mysql = require('mysql2/promise');
const bodyParser = require('body-parser');
const cors = require('cors');
require('dotenv').config();
const app = express();
const port = 5000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Database Connection
const db = mysql.createPool({
    host: process.env.DB_HOST || '127.0.0.1',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASS || '',
    database: process.env.DB_NAME || 'graduatedbooking',
});

// Centralized Error Handler
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Something went wrong', details: err.message });
});

// Routes

// Get all robes with filtering by size
app.get('/api/robes', async (req, res, next) => {
    const { size, status = 'Available', page = 1, limit = 10 } = req.query;
    const offset = (page - 1) * limit;

    try {
        let query = `
            SELECT * FROM robes
            WHERE size = ? AND status = ?
            LIMIT ? OFFSET ?`;
        const [rows] = await db.query(query, [size, status, parseInt(limit), parseInt(offset)]);
        res.status(200).json(rows);
    } catch (error) {
        next(error);
    }
});

// Add a new robe
app.post('/api/robes', async (req, res, next) => {
    const { type, size, price, image_url, status, date_range } = req.body;

    if (!type || !size || !price || status == null) {
        return res.status(400).json({ error: 'Required fields are missing' });
    }

    try {
        const query = `
            INSERT INTO robes (type, size, price, image_url, status, date_range)
            VALUES (?, ?, ?, ?, ?, ?)
        `;
        const [result] = await db.query(query, [type, size, price, image_url, status, date_range]);
        res.status(201).json({ message: 'Robe added successfully', id: result.insertId });
    } catch (error) {
        next(error);
    }
});

app.get('/api/outstanding-payment/:user_id', async (req, res, next) => {
    const { user_id } = req.params;

    try {
        const [rows] = await db.query(
            `
            SELECT SUM(r.price) AS total_outstanding
            FROM bookings b
            JOIN robes r ON b.robe_id = r.robe_id
            WHERE b.user_id = ? AND b.booking_date >= CURDATE()
            `,
            [user_id]
        );

        const totalOutstanding = rows[0].total_outstanding || 0;
        res.status(200).json({ outstanding_payment: totalOutstanding });
    } catch (error) {
        console.error(error);
        next(error);
    }
});

// Adding admin booking-specific endpoints
app.get('/api/bookings', async (req, res, next) => {
    const { robeType, size, status, collection_status, page = 1, limit = 10 } = req.query;
    const offset = (page - 1) * limit;

    try {
        // Construct the SQL query based on the filters
        let query = `
            SELECT b.booking_id, b.user_id, b.booking_date, b.status, b.collection_status, 
                   r.type AS robeType, r.size, r.price
            FROM bookings b
            JOIN robes r ON b.robe_id = r.robe_id
            WHERE 1 = 1`;

        const queryParams = [];

        if (robeType) {
            query += ' AND r.type = ?';
            queryParams.push(robeType);
        }

        if (size) {
            query += ' AND r.size = ?';
            queryParams.push(size);
        }

        if (status) {
            query += ' AND b.status = ?';
            queryParams.push(status);
        }

        if (collection_status) {
            query += ' AND b.collection_status = ?';
            queryParams.push(collection_status);
        }

        query += ' LIMIT ? OFFSET ?';
        queryParams.push(parseInt(limit), parseInt(offset));

        // Use the MySQL2 pool to execute the query
        const [rows] = await db.query(query, queryParams);

        // Send the results to the client
        res.status(200).json(rows);
    } catch (error) {
        console.error('Error fetching bookings:', error);
        next(error);
    }
});

// Update booking collection status
app.put('/api/bookings/:booking_id', async (req, res, next) => {
    const { booking_id } = req.params;
    const { collection_status } = req.body;

    // Validate input
    if (!collection_status) {
        return res.status(400).json({ error: 'Collection status is required.' });
    }

    try {
        // Determine the new status based on collection_status
        let status = null;
        if (collection_status === 'Returned') {
            status = 'Past';
        } else if (collection_status === 'Collected') {
            status = 'Active';
        }

        // Construct the update query
        let query = 'UPDATE bookings SET collection_status = ?';
        const queryParams = [collection_status];

        if (status) {
            query += ', status = ?';
            queryParams.push(status);
        }

        query += ' WHERE booking_id = ?';
        queryParams.push(booking_id);

        // Execute the update query
        const [result] = await db.query(query, queryParams);

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Booking not found.' });
        }

        res.status(200).json({ message: 'Booking updated successfully.' });
    } catch (error) {
        console.error('Error updating booking:', error);
        next(error);
    }
});

app.get('/api/inventory', async (req, res, next) => {
    const { robeType, size } = req.query;

    try {
        let query = 'SELECT * FROM robes WHERE 1 = 1';
        const queryParams = [];

        if (robeType) {
            query += ' AND type = ?';
            queryParams.push(robeType);
        }

        if (size) {
            query += ' AND size = ?';
            queryParams.push(size);
        }

        const [rows] = await db.query(query, queryParams);
        res.status(200).json(rows);
    } catch (error) {
        console.error('Error fetching inventory:', error);
        next(error);
    }
});

app.put('/api/inventory/:robe_id', async (req, res, next) => {
    const { robe_id } = req.params;
    const { robe_condition } = req.body;

    // Validate input
    if (!robe_condition) {
        return res.status(400).json({ error: 'Condition is required.' });
    }

    try {
        const query = 'UPDATE robes SET robe_condition = ? WHERE robe_id = ?';
        const [result] = await db.query(query, [robe_condition, robe_id]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Robe not found.' });
        }

        res.status(200).json({ message: 'Robe condition updated successfully.' });
    } catch (error) {
        console.error('Error updating condition:', error);
        next(error);
    }
});

app.get('/api/report', async (req, res) => {
    const { robeType, batch } = req.query;
  
    if (!robeType || !batch) {
      return res.status(400).json({ error: 'robeType and batch are required' });
    }
  
    try {
      // Fetch robe data grouped by size and batch
      const robeStockQuery = `
        SELECT size, COUNT(*) AS stock
        FROM robes
        WHERE type = ? AND batch = ?
        GROUP BY size;
      `;
      const [robeStockRows] = await db.query(robeStockQuery, [robeType, batch]);
  
      // Fetch collected robes grouped by size and batch
      const collectedQuery = `
        SELECT r.size, COUNT(*) AS collected
        FROM bookings b
        JOIN robes r ON b.robe_id = r.robe_id
        WHERE r.type = ? AND r.batch = ? AND b.status = 'Collected'
        GROUP BY r.size;
      `;
      const [collectedRows] = await db.query(collectedQuery, [robeType, batch]);
  
      // Fetch returned robes grouped by size and batch
      const returnedQuery = `
        SELECT r.size, COUNT(*) AS returned
        FROM bookings b
        JOIN robes r ON b.robe_id = r.robe_id
        WHERE r.type = ? AND r.batch = ? AND b.status = 'Returned'
        GROUP BY r.size;
      `;
      const [returnedRows] = await db.query(returnedQuery, [robeType, batch]);
  
      // Merge all data into a unified structure
      const sizes = ['XS', 'S', 'M', 'L'];
      const result = sizes.reduce((acc, size) => {
        const stock = robeStockRows.find((row) => row.size === size)?.stock || 0;
        const collected = collectedRows.find((row) => row.size === size)?.collected || 0;
        const returned = returnedRows.find((row) => row.size === size)?.returned || 0;
  
        // Future requirement prediction (20% of stock as an example)
        const futureReq = Math.ceil(stock * 0.2);
  
        acc[size] = {
          stock,
          collected,
          returned,
          future_req: futureReq,
        };
        return acc;
      }, {});
  
      res.status(200).json({ sizes: result });
    } catch (error) {
      console.error('Error fetching report data:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });  

// Admin Dashboard API
app.get('/api/admin-dashboard', async (req, res) => {
    const { robeType, size } = req.query;
  
    if (!robeType || !size) {
      return res.status(400).json({ error: 'robeType and size are required' });
    }
  
    try {
      // Fetch ready stock overview
      const readyStockQuery = `
        SELECT size, COUNT(*) AS readyStock
        FROM robes
        WHERE type = ? AND status = 'Available'
        GROUP BY size;
      `;
      const [readyStock] = await db.query(readyStockQuery, [robeType]);
  
      // Fetch booking statuses
      const bookingStatusQuery = `
        SELECT b.booking_id AS bookingId, r.size, b.status
        FROM bookings b
        JOIN robes r ON b.robe_id = r.robe_id
        WHERE r.type = ? AND r.size = ?;
      `;
      const [bookingStatuses] = await db.query(bookingStatusQuery, [robeType, size]);
  
      // Fetch flagged items
      const flaggedItemsQuery = `
        SELECT r.robe_id AS robeId, r.size, r.robe_condition AS flaggedCondition
        FROM robes r
        WHERE r.type = ? AND r.size = ? AND r.robe_condition IN ('Perfect','Maintenance', 'Repair');
      `;
      const [flaggedItems] = await db.query(flaggedItemsQuery, [robeType, size]);
  
      // Return combined data
      res.status(200).json({
        readyStock: readyStock.reduce((acc, row) => {
          acc[row.size] = row.readyStock;
          return acc;
        }, {}),
        bookingStatuses,
        flaggedItems,
      });
    } catch (error) {
      console.error('Error fetching admin dashboard data:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });

// Add centralized API test route
app.get('/api/test', (req, res) => {
    res.status(200).json({ message: 'API is working correctly!' });
});

// Start server
app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});
