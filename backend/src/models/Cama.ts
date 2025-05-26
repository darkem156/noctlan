import { DataTypes } from "sequelize";

export default {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  numero: {
    type: DataTypes.STRING,
    allowNull: false
  },
  cuartoId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: "Cuartos",
      key: "id"
    },
    onUpdate: "CASCADE",
    onDelete: "CASCADE"
  },
};
