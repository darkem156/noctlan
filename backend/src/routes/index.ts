import { Router } from 'express'
import commentsRouter from './comment'
import { signUp, signIn } from '../controllers/users'
import { Usuarios } from '../models/sequelize'

const router = Router()

router.get('/', async (req, res) => {
  res.send('Hello World')
})

router.post('/signUp', signUp)
router.post('/signIn', signIn)

//router.use('/comments', commentsRouter)

export default router
