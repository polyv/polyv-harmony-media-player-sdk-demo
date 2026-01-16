export class PLVMediaPlayerKnowledgeVO {
  fullScreenStyle?: boolean
  wordTypes?: PLVMediaPlayerKnowledgeVO_WordType[]
}

export class PLVMediaPlayerKnowledgeVO_WordType {
  name?: string
  wordKeys?: PLVMediaPlayerKnowledgeVO_WordKey[]
}

export class PLVMediaPlayerKnowledgeVO_WordKey {
  name?: string
  knowledgePoints?: PLVMediaPlayerKnowledgeVO_KnowledgePoint[]
}

export class PLVMediaPlayerKnowledgeVO_KnowledgePoint {
  name?: string
  time?: number
}