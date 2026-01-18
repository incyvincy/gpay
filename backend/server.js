const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Database Connection
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'gpay_db',
  password: 'ch24b050', // <--- REPLACE THIS WITH YOUR POSTGRES PASSWORD
  port: 5432,
});

// --- ROUTES ---

pool.connect((err, client, release) => {
  if (err) {
    return console.error('Error acquiring client', err.stack);
  }
  client.query('SELECT NOW()', (err, result) => {
    release(); // Release the client back to the pool
    if (err) {
      return console.error('Error executing query', err.stack);
    }
    console.log("✅ Connected to Database 'gpay_db' Successfully!");
  });
});

// 1. Login Route (Checks Encrypted Password)
app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    // Normalize email to lowercase for case-insensitive matching
    const normalizedEmail = email.toLowerCase();
    
    // This SQL checks if the password matches the encrypted one
    const result = await pool.query(
      "SELECT * FROM users WHERE email = $1 AND password = crypt($2, password)",
      [normalizedEmail, password]
    );
    
    if (result.rows.length > 0) {
      res.json({ success: true, user: result.rows[0] });
    } else {
      res.status(401).json({ success: false, message: "Invalid credentials" });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 2. Transaction Route (Updated to track Receiver Email)
app.post('/pay', async (req, res) => {
  const { amount, receiver_name, upi_id, sender_email } = req.body;
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    // Check Balance
    const userRes = await client.query("SELECT balance FROM users WHERE email = $1", [sender_email]);
    if (userRes.rows.length === 0) throw new Error("User not found");
    
    const currentBalance = parseFloat(userRes.rows[0].balance);
    const payAmount = parseFloat(amount);

    // Security Check: Block negative or zero amounts
    if (payAmount <= 0) {
        throw new Error("Invalid amount. Cannot pay negative or zero.");
    }

    if (currentBalance < payAmount) throw new Error("Insufficient Balance");

    // Deduct Balance
    await client.query("UPDATE users SET balance = balance - $1 WHERE email = $2", [payAmount, sender_email]);

    // Check if the Receiver exists in our DB (to show in their history later)
    // We assume the 'upi_id' might be their email for this demo
    let receiverEmail = null;
    const receiverCheck = await client.query("SELECT email FROM users WHERE email = $1", [upi_id]);
    if (receiverCheck.rows.length > 0) {
        receiverEmail = receiverCheck.rows[0].email;
        // Optional: Add money to receiver if they exist
        await client.query("UPDATE users SET balance = balance + $1 WHERE email = $2", [payAmount, receiverEmail]);
    }

    // Save Transaction
    await client.query(
      "INSERT INTO transactions (amount, receiver_name, upi_id, sender_email, receiver_email, status, date) VALUES ($1, $2, $3, $4, $5, 'Success', NOW())",
      [payAmount, receiver_name, upi_id, sender_email, receiverEmail]
    );

    await client.query('COMMIT');
    res.json({ success: true, message: "Payment Successful" });

  } catch (err) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
});

// 3. Signup Route (Creates a new user)
app.post('/signup', async (req, res) => {
  const { name, email, password } = req.body;
  try {
    // Normalize email to lowercase for consistent storage
    const normalizedEmail = email.toLowerCase();
    
    // Check if user already exists
    const userCheck = await pool.query("SELECT * FROM users WHERE email = $1", [normalizedEmail]);
    if (userCheck.rows.length > 0) {
      return res.status(400).json({ success: false, message: "User already exists" });
    }

    // Insert new user with encrypted password
    // We give them 1000 balance by default
    const newUser = await pool.query(
      "INSERT INTO users (name, email, password, balance) VALUES ($1, $2, crypt($3, gen_salt('bf')), 1000.00) RETURNING id, name, email",
      [name, normalizedEmail, password]
    );

    res.json({ success: true, user: newUser.rows[0] });
  } catch (err) {
    // Handle unique name error specific code (23505 is unique violation)
    if (err.code === '23505') {
       return res.status(400).json({ success: false, message: "Name or Email already taken" });
    }
    res.status(500).json({ error: err.message });
  }
});

// 4. History Route (New)
app.post('/history', async (req, res) => {
    const { email } = req.body;
    try {
        const result = await pool.query(
            `SELECT * FROM transactions 
             WHERE sender_email = $1 OR receiver_email = $1 
             ORDER BY id DESC`,
            [email]
        );
        res.json({ success: true, transactions: result.rows });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Start Server
app.listen(3000, () => {
  console.log("Server running on port 3000");
});