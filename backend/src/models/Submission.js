import { DataTypes } from 'sequelize';
import sequelize from '../config/db.js';

const Submission = sequelize.define('Submission', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  fileUrl: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  grade: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  remarks: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
});

export default Submission;
