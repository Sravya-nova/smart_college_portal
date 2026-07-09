import { Sequelize } from 'sequelize';
import dotenv from 'dotenv';

dotenv.config();

const sequelize = new Sequelize({
  dialect: 'sqlite',
  storage: process.env.DB_STORAGE || 'database.sqlite',
  logging: false, // Disable logging queries in console for cleaner server outputs
});

export default sequelize;
