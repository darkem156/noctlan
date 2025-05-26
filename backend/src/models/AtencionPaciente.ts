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
    }
  },
  usuarioId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: "Usuarios",
      key: "id"
    }
  },
  camaId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: "Camas",
      key: "id"
    }
  },
  fecha_ingreso: {
    type: DataTypes.DATE,
    allowNull: false
  },
  fecha_salida: {
    type: DataTypes.DATE,
    allowNull: true
  }
};
