import { Sequelize } from 'sequelize'
import Usuario from './Usuario'
import Area from './Area'
import Cuarto from './Cuarto'
import Cama from './Cama'
import Paciente from './Paciente'
import AtencionPaciente from './AtencionPaciente'
import Metrica from './Metrica'

const host = process.env.DB_HOST || 'localhost'
const database = process.env.DB_NAME || 'noctlan'
const username = process.env.DB_USER || 'postgres'
const password = process.env.DB_PASS || 'password'

const sequelize = new Sequelize(database, username, password, {
  host,
  dialect: 'postgres'
})

export const Usuarios = sequelize.define('Usuario', Usuario, { timestamps: false })
export const Areas = sequelize.define('Area', Area, { timestamps: false })
export const Cuartos = sequelize.define('Cuarto', Cuarto, { timestamps: false })
export const Camas = sequelize.define('Cama', Cama, { timestamps: false })
export const Pacientes = sequelize.define('Paciente', Paciente, { timestamps: false })
export const Atenciones = sequelize.define('Atencion_paciente', AtencionPaciente, { timestamps: false })
export const Metricas = sequelize.define('Metrica', Metrica, { timestamps: false })
// Definición de relaciones
Usuarios.hasMany(Atenciones, { foreignKey: 'usuarioId' })
Atenciones.belongsTo(Usuarios, { foreignKey: 'usuarioId' })
Areas.hasMany(Cuartos, { foreignKey: 'areaId' })
Cuartos.belongsTo(Areas, { foreignKey: 'areaId' })
Cuartos.hasMany(Camas, { foreignKey: 'cuartoId' })
Camas.belongsTo(Cuartos, { foreignKey: 'cuartoId' })
Camas.hasMany(Atenciones, { foreignKey: 'camaId' })
Atenciones.belongsTo(Camas, { foreignKey: 'camaId' })
Pacientes.hasMany(Atenciones, { foreignKey: 'pacienteId' })
Atenciones.belongsTo(Pacientes, { foreignKey: 'pacienteId' })
Pacientes.hasMany(Metricas, { foreignKey: 'pacienteId' })
Metricas.belongsTo(Pacientes, { foreignKey: 'pacienteId' })

;(async () => {
  try {
    await sequelize.sync()
  } catch (error) {
    console.error(error)
  }
})()
