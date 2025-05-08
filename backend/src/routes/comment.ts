import { Router } from 'express'
import { createComment, deleteComment, editComment, getComments } from '../controllers/comment'

const router = Router()

router.post('/newComment', createComment)
router.get('/', getComments)
router.put('/:id', editComment)
router.delete('/:id', deleteComment)

export default router
