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

// 2. Transaction Route (Deducts Balance + Saves Record)
app.post('/pay', async (req, res) => {
  const { amount, receiver_name, upi_id, sender_email } = req.body;
  
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN'); // Start Transaction

    // Step A: Check if user has enough balance
    const userRes = await client.query("SELECT balance FROM users WHERE email = $1", [sender_email]);
    if (userRes.rows.length === 0) {
        throw new Error("User not found");
    }
    const currentBalance = parseFloat(userRes.rows[0].balance);
    const payAmount = parseFloat(amount);

    if (currentBalance < payAmount) {
        throw new Error("Insufficient Balance");
    }

    // Step B: Deduct Balance
    await client.query("UPDATE users SET balance = balance - $1 WHERE email = $2", [payAmount, sender_email]);

    // Step C: Save Transaction
    await client.query(
      "INSERT INTO transactions (amount, receiver_name, upi_id, sender_email, status) VALUES ($1, $2, $3, $4, 'Success')",
      [payAmount, receiver_name, upi_id, sender_email]
    );

    await client.query('COMMIT'); // Save Changes
    res.json({ success: true, message: "Payment Successful" });

  } catch (err) {
    await client.query('ROLLBACK'); // Undo if error
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

// Start Server
app.listen(3000, () => {
  console.log("Server running on port 3000");
});
