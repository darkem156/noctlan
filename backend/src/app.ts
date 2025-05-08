import express from 'express'
import morgan from 'morgan'
import cors from 'cors'
import router from './routes/index'

const app = express()

app.set('port', process.env.PORT ?? 3000)

app.use(express.json())
app.use(morgan('dev'))
app.use(cors({
  origin: '*'
}))

app.use('/', router)

export default app
