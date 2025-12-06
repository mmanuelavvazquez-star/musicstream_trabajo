/* global use, db */
// MongoDB Playground
// Use Ctrl+Space inside a snippet or a string literal to trigger completions.

const database = 'NEW_DATABASE_NAME';
const collection = 'NEW_COLLECTION_NAME';

// Create a new database.
use('bd030');

// Create a new collection.

db.createCollection('playlist');
db.createCollection('play_history');
db.createCollection('follows');
// The prototype form to create a collection:
/* db.createCollection( <name>,
  {
    capped: <boolean>,
    autoIndexId: <boolean>,
    size: <number>,
    max: <number>,
    storageEngine: <document>,
    validator: <document>,
    validationLevel: <string>,
    validationAction: <string>,
    indexOptionDefaults: <document>,
    viewOn: <string>,
    pipeline: <pipeline>,
    collation: <document>,
    writeConcern: <document>,
    timeseries: { // Added in MongoDB 5.0
      timeField: <string>, // required for time series collections
      metaField: <string>,
      granularity: <string>,
      bucketMaxSpanSeconds: <number>, // Added in MongoDB 6.3
      bucketRoundingSeconds: <number>, // Added in MongoDB 6.3
    },
    expireAfterSeconds: <number>,
    clusteredIndex: <document>, // Added in MongoDB 5.3
  }
)*/

// More information on the `createCollection` command can be found at:
// https://www.mongodb.com/docs/manual/reference/method/db.createCollection/

//PLAYLIST: 
db.playlist.insertOne({
  id: "PL0001",
  title: "Morning Vibes",
  description: "Playlist de ejemplo para modelación",
  total_songs: 2,
  duration: 7.43,
  cover_photo:"https://picsum.photos/300",
  user_id: "user_1",
  songs: [
    //embebing
    {song_id: "SNG0001", 
    title: "Love Story",
    duration: 3.45 },
    {song_id: "SNG0002",
    title: "Blinding Lights",
    duration: 3.98 }
  ]
});


//PLAY_HISTORY: referencing
db.play_history.insertOne({
  id:"PH0101276",
  user_id: "user_1",
  song_id: "SNG0014",
  device_id:"D000011",
  playlist_id:null,
  play_date:new Date("2025-06-19"),
  duration_played: 2.83,
  completed: true
});

//FOLLOWS
db.follows.insertOne({
  _id: "user_1",
  following_artists: ["ART001", "ART004", "ART020"],
  following_users: ["user_3", "user_15"],
  followers: ["user_8", "user_22"]
});


//exemplos
db.playlist.find()
db.play_history.countDocuments()
db.follows.find({ _id: "user_1" })
db.play_history.find(
  {},
  {completed:0}
)
db.playlist.find({ "songs.song_id": "SNG0001" })



db.playlist.drop()









