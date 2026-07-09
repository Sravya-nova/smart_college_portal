import { DataTypes } from 'sequelize';
import sequelize from '../config/db.js';

const Notice = sequelize.define('Notice', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  snippet: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  category: {
    type: DataTypes.ENUM('Academic', 'Events', 'Placement', 'Administrative'),
    allowNull: false,
    defaultValue: 'Academic',
  },
  imageUrl: {
    type: DataTypes.STRING,
    allowNull: true,
  },
});

export default Notice;
