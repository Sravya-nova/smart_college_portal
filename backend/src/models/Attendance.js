import { DataTypes } from 'sequelize';
import sequelize from '../config/db.js';

const Attendance = sequelize.define('Attendance', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  date: {
    type: DataTypes.DATEONLY,
    allowNull: false,
  },
  status: {
    type: DataTypes.ENUM('Present', 'Absent'),
    allowNull: false,
    defaultValue: 'Present',
  },
});

export default Attendance;
