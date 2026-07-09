import { DataTypes } from 'sequelize';
import sequelize from '../config/db.js';

const Application = sequelize.define('Application', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  status: {
    type: DataTypes.ENUM('Applied', 'Shortlisted', 'Interviewing', 'Selected', 'Rejected'),
    allowNull: false,
    defaultValue: 'Applied',
  },
});

export default Application;
