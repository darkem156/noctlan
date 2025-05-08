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
  apellido: {
    type: DataTypes.STRING,
    allowNull: false
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
    validate: { isEmail: true }
  },
  contraseña_hash: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  tipo_usuario: {
    type: DataTypes.ENUM("administrador", "medico", "enfermero"),
    allowNull: false
  },
  creado_en: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  },
};
