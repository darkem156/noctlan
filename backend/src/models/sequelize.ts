import { Sequelize } from 'sequelize'
import Usuario from './Usuario'

const host = process.env.DB_HOST || 'localhost'
const database = process.env.DB_NAME || 'noctlan'
const username = process.env.DB_USER || 'postgres'
const password = process.env.DB_PASS || 'password'

const sequelize = new Sequelize(database, username, password, {
  host,
  dialect: 'postgres'
})

export const Usuarios = sequelize.define('usuario', Usuario, { timestamps: false })

;(async () => {
  try {
    await sequelize.sync()
  } catch (error) {
    console.error(error)
  }
})()
