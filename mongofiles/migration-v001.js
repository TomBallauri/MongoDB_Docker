const blogDb = db.getSiblingDB("blog_db");

blogDb.createCollection("posts", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["titre", "auteur", "vues"],
      additionalProperties: false,
      properties: {
        _id: { bsonType: "objectId" },
        titre: {
          bsonType: "string",
          description: "titre must be a string and is required"
        },
        auteur: {
          bsonType: "string",
          description: "auteur must be a string and is required"
        },
        vues: {
          bsonType: "number",
          description: "vues must be a number and is required"
        }
      }
    }
  },  
  validationLevel: "strict",
  validationAction: "error"
});