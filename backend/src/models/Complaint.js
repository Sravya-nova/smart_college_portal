import { DataTypes } from 'sequelize';
import sequelize from '../config/db.js';

const Complaint = sequelize.define('Complaint', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  status: {
    type: DataTypes.ENUM('Pending', 'InProgress', 'Resolved'),
    allowNull: false,
    defaultValue: 'Pending',
  },
});

export default Complaint;
