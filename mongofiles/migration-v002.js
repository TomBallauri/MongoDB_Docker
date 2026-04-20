const blogDb = db.getSiblingDB("blog_db");

blogDb.posts.insertMany([
  { titre: "Article 1", auteur: "Alice", vues: 100 },
  { titre: "Article 2", auteur: "Bob", vues: 250 },
  { titre: "Article 3", auteur: "Alice", vues: 80 },
  { titre: "Article 4", auteur: "Charlie", vues: 430 },
  { titre: "Article 5", auteur: "Pierre", vues: 170 }
]);