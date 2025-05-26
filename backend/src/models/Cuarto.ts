import { DataTypes } from "sequelize";

export default {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  nombre: {
    type: DataTypes.STRING,
    allowNull: false
  },
  areaId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: "Areas",
      key: "id"
    },
    onUpdate: "CASCADE",
    onDelete: "CASCADE"
  }
};
