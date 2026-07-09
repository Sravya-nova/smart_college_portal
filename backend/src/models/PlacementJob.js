import { DataTypes } from 'sequelize';
import sequelize from '../config/db.js';

const PlacementJob = sequelize.define('PlacementJob', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  company: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  requirements: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  deadline: {
    type: DataTypes.DATE,
    allowNull: false,
  },
});

export default PlacementJob;
