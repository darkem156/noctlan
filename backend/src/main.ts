import app from './app'

app.listen(app.get('port'), () => {
  const port: number = app.get('port')
  console.log(`Server on port ${port}`)
})
