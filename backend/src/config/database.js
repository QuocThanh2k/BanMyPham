const sql = require('mssql');

const dbConfig = {
  server: "localhost",
  database: "ThanhtamCosmetics",
  driver: "mssql",
  options: {
    instanceName: "QUOCTHANH",
    trustedConnection: true,
    trustServerCertificate: true,
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000,
  },
};

const connectDB = async () => {
  try {
    const pool = await sql.connect(dbConfig);
    console.log('✅ Đã kết nối MS SQL Server (.\\QUOCTHANH) bằng Windows Auth thành công!');
    return pool;
  } catch (err) {
    console.error('❌ Kết nối CSDL thất bại:', err);
    process.exit(1);
  }
};

module.exports = { sql, connectDB };