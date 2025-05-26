import { Router } from 'express'
import commentsRouter from './comment'
import { signUp, signIn } from '../controllers/users'
import { Usuarios } from '../models/sequelize'
import { Pacientes, Atenciones } from '../models/sequelize'

const router = Router()

router.get('/', async (req, res) => {
  res.send('Hello World')
})

router.post('/signUp', signUp)
router.post('/signIn', signIn)

router.get('/usuarios', async (req, res) => {
  try {
    const usuarios = await Usuarios.findAll()
    return res.status(200).json(usuarios)
  }
  catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Internal Server Error' })
  }
})

router.post('/pacientes', async (req, res) => {
  try {
    const { nombre, apellido, fechaNacimiento, genero } = req.body
    console.log(fechaNacimiento)
    if (!nombre || !apellido || !fechaNacimiento || !genero) {
      return res.status(400).json({ message: 'Bad Request' })
    }
    const paciente = await Pacientes.create({
      nombre,
      apellido,
      fecha_nacimiento: fechaNacimiento,
      genero
    })
    return res.status(201).json(paciente)
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Internal Server Error' })
  }
})

router.get('/pacientes', async (req, res) => {
  try {
    const pacientes = await Pacientes.findAll()
    return res.status(200).json(pacientes)
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Internal Server Error' })
  }
})

//router.use('/comments', commentsRouter)

export default router
