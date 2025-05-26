import { DataTypes } from "sequelize";

export default {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  pacienteId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: "Pacientes",
      key: "id"
    },
    onUpdate: "CASCADE",
    onDelete: "CASCADE"
  },
  ritmo_cardiaco: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  respiracion: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  ruido_ambiental: {
    type: DataTypes.FLOAT,
    allowNull: false
  },
  timestamp: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
};
