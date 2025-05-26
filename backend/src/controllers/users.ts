import { Request, Response } from "express";
import jwt from "jsonwebtoken";
import bcrypt from "bcrypt";
import { Usuarios } from '../models/sequelize'

export async function signUp(req: Request, res: Response) {
  try {
    const token = req.headers["authorization"]
    if(!token) {
      return res.status(401).json({ message: "Unauthorized" });
    }
    const user_data = jwt.verify(token, process.env.JWT_SECRET || "secret")
    console.log(user_data)
    if(user_data.tipo_usuario !== "administrador") {
      return res.status(403).json({ message: "Forbidden" });
    }
    console.log(req.body)
    const { nombre, apellido, email, password, tipo_usuario } = req.body;
    if(tipo_usuario === "administrador") {
      return res.status(403).json({ message: "Forbidden" });
    }
    const emailRegex = /[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/
    if(!nombre || !apellido || !email || !password || !tipo_usuario) {
      res.status(400).json({ message: "Bad Request" });
      return
    }
    if(!emailRegex.test(email)) {
      res.status(400).json({ message: "Bad Request" });
      return
    }
    const contraseña_hash = await bcrypt.hash(password, 10);
    const newUser = await Usuarios.upsert({ nombre, apellido, email, contraseña_hash, tipo_usuario });
    return res.status(201).json(newUser);
  } catch (error) {
    console.log(error)
    return res.status(500).json({ message: "Internal Server Error: "+error });
  }
}

export async function signIn(req: Request, res: Response) {
  try {
    const { email, password } = req.body;
    if(!email || !password) {
      res.status(400).json({ message: "Bad Request" });
      return
    }
    const user = await Usuarios.findOne({ where: { email } });
    if (!user) {
      return res.status(401).json({ message: "Unauthorized" });
    }
    const isValidPassword = await bcrypt.compare(password, user.dataValues.contraseña_hash);
    if (!isValidPassword) {
      return res.status(401).json({ message: "Unauthorized" });
    }
    const token = jwt.sign({ id: user.dataValues.id, tipo_usuario: user.dataValues.tipo_usuario }, process.env.JWT_SECRET || "secret", { expiresIn: "1h" });
    return res.status(200).json({ token });
  } catch (error) {
    console.log(error)
    return res.status(500).json({ message: "Internal Server Error" });
  }
}