import { Request, Response } from "express";
import { Comment } from "../models/sequelize";

export async function createComment(req: Request, res: Response) {
  try {
    const { comment, email } = req.body;
    let { fatherComment } = req.body;
    const emailRegex = /[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/
    if(!comment || !email || !emailRegex.test(email)) {
      res.status(400).json({ message: "Bad Request" });
      return
    }
    if(fatherComment == -1) fatherComment = 0
    const newComment = await Comment.create({ comment, email, fatherCommentId: fatherComment });
    res.json(newComment);
    return
  } catch (error) {
    res.status(500).json({ message: "Internal Server Error" });
  }
}

interface IComment {
  comment: string
  email: string
  subComments: IComment[]
}

export async function getComments(req: Request, res: Response) {
  try {
    const comments = await Comment.findAll();
    res.json(comments);
    return
  } catch (error) {
    res.status(500).json({ message: "Internal Server Error" });
  }
}

export async function editComment(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const { comment } = req.body;
    const updatedComment = await Comment.update({ comment }, { where: { id } });
    res.json({ message: "Comment updated" });
  } catch (error) {
    res.status(500).json({ message: "Internal Server Error" });
  }
}

export async function deleteComment(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const deletedComment = await Comment.destroy({ where: { id } });
    res.json({ message: "Comment deleted" });
  } catch (error) {
    res.status(500).json({ message: "Internal Server Error" });
  }
}