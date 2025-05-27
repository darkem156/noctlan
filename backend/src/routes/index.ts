import { Router } from 'express'
import commentsRouter from './comment'
import { Request, Response } from "express";
import { signUp, signIn } from '../controllers/users'
import {
  Usuarios,
  Pacientes,
  Atenciones,
  Areas,
  Cuartos,
  Camas,
  Metricas
} from '../models/sequelize'

const router = Router()

// Root
router.get('/', async (req, res) => {
  res.send('Hello World')
})

// AUTH
router.post('/signUp', signUp)
router.post('/signIn', signIn)

// USUARIOS
router.get('/usuarios', async (req, res) => {
  try {
    const usuarios = await Usuarios.findAll()
    return res.status(200).json(usuarios)
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Internal Server Error' })
  }
})

// PACIENTES
router.get('/pacientes', async (req, res) => {
  try {
    const pacientes = await Pacientes.findAll({
      include: [{
        model: Atenciones,
        as: 'Atencion_pacientes',
        attributes: ['id', 'fecha_ingreso', 'fecha_salida'],
        include: [{
          model: Usuarios,
          as: 'Usuario',
          attributes: ['id', 'nombre', 'apellido']
        }, {
          model: Camas,
          as: 'Cama',
          attributes: ['id', 'numero'],
          include: [{
            model: Cuartos,
            as: 'Cuarto',
            attributes: ['id', 'nombre']
          }]
        }]
      }]
    })
    console.log(pacientes[0].dataValues)
    return res.status(200).json(pacientes)
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Error al obtener pacientes' })
  }
})

router.post('/pacientes', async (req, res) => {
  try {
    const { nombre, apellido, fechaNacimiento, genero } = req.body
    if (!nombre || !apellido || !fechaNacimiento || !genero) {
      return res.status(400).json({ message: 'Faltan campos requeridos' })
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
    return res.status(500).json({ message: 'Error al crear paciente' })
  }
})

// routes/pacientes.js

router.patch('/pacientes/:id', async (req, res) => {
  const { id } = req.params;
  const { camaId, usuarioId } = req.body;
  console.log(id, camaId, usuarioId)

  try {
    // Verificar que el paciente existe
    const paciente = await Pacientes.findByPk(id);
    if (!paciente) {
      return res.status(404).json({ message: 'Paciente no encontrado' });
    }

    const cama = await Camas.findOne({
      where: { id: camaId }});

    if (!cama) {
      return res.status(404).json({ message: 'Cama no encontrada' });
    }

    // Asignar la cama al paciente
    const atencion = await Atenciones.create({
      pacienteId: id,
      usuarioId,
      camaId: camaId,
      fecha_ingreso: new Date(),
      fecha_salida: null // Puedes ajustar esto según tu lógica
    });

    return res.status(200).json({ message: 'Cama asignada correctamente al paciente' });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Error al asignar cama al paciente' });
  }
});

router.delete('/pacientes/:id', async (req, res) => {
  try {
    const { id } = req.params
    const paciente = await Pacientes.destroy({ where: { id } })
    if (!paciente) return res.status(404).json({ message: 'Paciente no encontrado' })
    return res.status(200).json({ message: 'Paciente eliminado' })
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Error al eliminar paciente' })
  }
})

// ÁREAS
router.get('/areas', async (req, res) => {
  try {
    const areas = await Areas.findAll()
    return res.status(200).json(areas)
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Error al obtener áreas' })
  }
})

router.post('/areas', async (req, res) => {
  try {
    const { nombre } = req.body
    if (!nombre) return res.status(400).json({ message: 'Nombre requerido' })
    const area = await Areas.create({ nombre })
    return res.status(201).json(area)
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Error al crear área' })
  }
})

router.delete('/areas/:id', async (req, res) => {
  try {
    const { id } = req.params
    const area = await Areas.destroy({ where: { id } })
    if (!area) return res.status(404).json({ message: 'Área no encontrada' })
    return res.status(200).json({ message: 'Área eliminada' })
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Error al eliminar área' })
  }
})

// CUARTOS
router.get('/cuartos', async (req, res) => {
  try {
    const { areaId } = req.query

    const cuartos = await Cuartos.findAll({
      where: areaId ? { area_id: areaId } : undefined,
      include: {
        model: Areas,
        as: 'Area', // Usa el alias que tengas definido en la relación, si es necesario
        attributes: ['id', 'nombre'] // Incluye los campos que necesites
      }
    })
    console.log(cuartos)

    return res.status(200).json(cuartos)
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Error al obtener cuartos' })
  }
})

router.post('/cuartos', async (req, res) => {
  try {
    const { numero, areaId } = req.body
    const nombre = `Cuarto ${numero}`
    if (!nombre || !areaId) return res.status(400).json({ message: 'Faltan campos' })
    const cuarto = await Cuartos.create({ nombre, areaId: areaId })
    return res.status(201).json(cuarto)
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Error al crear cuarto' })
  }
})

// Eliminar un cuarto
router.delete('/cuartos/:id', async (req, res) => {
  try {
    const { id } = req.params
    const cuarto = await Cuartos.destroy({ where: { id } })
    if (!cuarto) return res.status(404).json({ message: 'Cuarto no encontrado' })
    return res.status(200).json({ message: 'Cuarto eliminado' })
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Error al eliminar cuarto' })
  }
})

// CAMAS
router.get('/camas', async (req, res) => {
  try {
    const camas = await Camas.findAll(
      { include: [{
        model: Cuartos,
        as: 'Cuarto', // Usa el alias que tengas definido en la relación, si es necesario
        attributes: ['id', 'nombre'] // Incluye los campos que necesites
      }, {
        model: Atenciones,
        as: 'Atencion_pacientes',
        include: [{
          model: Usuarios,
          as: 'Usuario',
          attributes: ['id', 'nombre', 'apellido']
        }]
      }]}
    )
    return res.status(200).json(camas)
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Error al obtener camas' })
  }
})

router.post('/camas', async (req, res) => {
  try {
    const { numero, cuartoId } = req.body
    if (!numero || !cuartoId) return res.status(400).json({ message: 'Faltan campos' })
    const cama = await Camas.create({ numero, cuartoId: cuartoId })
    return res.status(201).json(cama)
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Error al crear cama' })
  }
})

// PUT /camas/:id/asignar-medico
router.put('/camas/:id/asignar-medico', async (req, res) => {
  try {
    const camaId = req.params.id;
    const { medicoId } = req.body;

    const cama = await Camas.findByPk(camaId);
    if (!cama) return res.status(404).json({ message: 'Cama no encontrada' });

    cama.medicoId = medicoId;
    await cama.save();

    return res.status(200).json({ message: 'Cama actualizada' });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Error al asignar médico' });
  }
});


// Eliminar una cama
router.delete('/camas/:id', async (req, res) => {
  try {
    const { id } = req.params
    const cama = await Camas.destroy({ where: { id } })
    if (!cama) return res.status(404).json({ message: 'Cama no encontrada' })
    return res.status(200).json({ message: 'Cama eliminada' })
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Error al eliminar cama' })
  }
})

// ATENCIÓN PACIENTE
router.get('/atenciones', async (req, res) => {
  try {
    const atenciones = await Atenciones.findAll()
    return res.status(200).json(atenciones)
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Error al obtener atenciones' })
  }
})

router.post('/atenciones', async (req, res) => {
  try {
    const { pacienteId, usuarioId, camaId, fechaInicio, fechaFin } = req.body
    if (!pacienteId || !camaId || !fechaInicio) {
      return res.status(400).json({ message: 'Faltan datos requeridos' })
    }
    const atencion = await Atenciones.create({
      paciente_id: pacienteId,
      usuarioId,
      cama_id: camaId,
      fecha_inicio: fechaInicio,
      fecha_fin: fechaFin || null
    })
    return res.status(201).json(atencion)
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Error al registrar atención' })
  }
})

// MÉTRICAS
router.get('/metricas', async (req, res) => {
  try {
    const metricas = await Metricas.findAll()
    return res.status(200).json(metricas)
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Error al obtener métricas' })
  }
})

router.get('/metricas/paciente/:pacienteId', async (req, res) => {
  try {
    const { pacienteId } = req.params
    const metricas = await Metricas.findAll({ where: { paciente_id: pacienteId } })
    return res.status(200).json(metricas)
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Error al obtener métricas del paciente' })
  }
})

router.post('/metricas', async (req, res) => {
  try {
    const { pacienteId, respiracion, ritmoCardiaco, ruido, fecha } = req.body
    if (!pacienteId || !fecha) return res.status(400).json({ message: 'Faltan campos' })
    const metrica = await Metricas.create({
      paciente_id: pacienteId,
      respiracion,
      ritmo_cardiaco: ritmoCardiaco,
      ruido,
      fecha
    })
    return res.status(201).json(metrica)
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: 'Error al registrar métrica' })
  }
})

export default router
