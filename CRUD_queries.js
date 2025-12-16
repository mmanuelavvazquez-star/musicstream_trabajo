// 15 CRUD queries
// CRUD operations are the following four basic functions:
// CREATE: insert new docs
// READ: read existing docs
// UPDATE: modify existing docs
// DELETE: remove docs


// 1. READ: user playlist statistics aggregated by song count
// Objective: to list users with their playlist statistics in descending order of total number of songs added to their playlist
db.playlist.aggregate([
  {
    $group: { 
      _id: "$user_id", 
      tot_playlists: {$sum: 1}, 
      tot_songs: {$sum: "$total_songs"}, 
      average_duration: {$avg: "$duration"} 
    }
  },
  {
    $sort: {tot_songs: -1}
  }
])

// 2. READ: most listened songs per user
// Objective: obtain the top 10 most listened songs by a specific user (we have chosen user_9)
db.play_history.aggregate([
  {
    $match: {
      user_id: "user_9",
    }
  },
  {
    $group: {
      _id: "$song_id",
      play_count: {$sum: 1},
      tot_duration: {$sum: "$duration"}
    }
  },
  {
    $sort: {play_count: -1}
  },
  {
    $limit: 10
  }
])

// 3. READ: songs per artist with statistics
// Objective: to show a summary of the statistics of an artist's songs
db.songs.aggregate([
  {
    $group: {
      _id: "$artist",
      song_count: {$sum: 1},
      total_duration: {$sum: "$duration"},
      avg_popularity: {$avg: "$popularity"},
      max_plays: {$max: "$play_count"}
    }
  },
  {
    $sort: {song_count: -1}
  }
])

// 4. READ: daily statistics of completed plays
// Objective: to obtain a daily report of all songs played (those that have been marked as listened)
db.play_history.aggregate([
  {
    $match: {
      completed: true
    }
  },
  {
    $group: {
      _id: "$play_date",
      total_plays: {$sum: 1},
      unique_users: {$addToSet: "$user_id"},
      avg_duration: {$avg: "$duration_played"}
    }
  },
  {
    $project: {
      _id: 0,
      date: "$_id",
      total_plays: 1,
      unique_users_count: {$size: "$unique_users"},
      avg_duration: 1
    }
  },
  {
    $sort: {date: 1}
  }
])

// 5. UPDATE: update of some of user_16's login data
// Objective: to update the register of user_16, updating their last login, increasing the counter
db.users.updateOne(
  {user_id: "user_16"},
  {
    $set: {last_login: new Date()},
    $inc: {login_count: 1},
    $push: { 
      login_history: {
        date: new Date(),
        ip: "192.168.1.1"
      }
    }
  }
)

// 6. UPDATE: to update a song's popularity
// Objective: for all songs that have been played >1000 times, to change their status to trending and increase their popularity score by 10%
db.songs.updateMany(
  { play_count: {$gt: 1000}},
  {
    $mul: {popularity_score: 1.1},
    $set: {trending: true}
  }
)

// 7. CREATE: creation of a new user with embedded preferences
// Objective: to insert a new user into the system
db.users.insertOne({
  user_id: "user_" + Date.now(), // We have chosen this user_id to avoid repetitions with existing users
  username: "new_usuario",
  email: "usuer@email.com",
  subscription: {
    type: "premium",
    start_date: new Date(),
    active: true
  },
  preferences: {
    favorite_genres: ["Rock", "Jazz"],
    explicit_content: false,
    autoplay: true
  },
  stats: {
    play_count: 0,
    playlist_count: 0
  }
})

// 8. READ: join playlists with their owners
// Objective: combine user + playlist data and display who owns each playlist
db.playlist.aggregate([
  {
    $lookup: {
      from: "users",
      localField: "user_id",
      foreignField: "id",  
      as: "user_info"
    }
  },
  {
    $unwind: "$user_info"
  }
])

// 9. DELETE: deletion of old playback history
// Objectv¡e: to remove play history entries which are older than 1 year and have less than 5 plays
db.play_history.deleteMany({
  play_date: { 
    $lt: new Date(Date.now() - 365 * 24 * 60 * 60 * 1000) 
  },
  play_count: {$lt: 5}
})

// 10. READ: top 5 most active users by creation of playlists
// Objective: identify the most active users based on the nº of playlists created
db.playlist.aggregate([
  {
    $group: {
      _id: "$user_id",
      playlist_count: {$sum: 1},
      total_songs_in_playlists: {$sum: "$total_songs"},
      avg_playlist_duration: {$avg: "$duration"}
    }
  },
  {
    $sort: {playlist_count: -1}
  },
  {
    $limit: 5
  },
  {
    $project: {
      _id: 0,
      user_id: "$_id",
      playlist_count: 1,
      total_songs_in_playlists: 1,
      avg_playlist_duration: {$round: ["$avg_playlist_duration", 2]}
    }
  }
])

// 11. UPDATE: increase play count and update the timestamp for the last time SNG0026 was played
// Objective: to add 1 to a song's play count every time user_9 plays it and change its timestamp to the current time
db.songs.updateOne(
  {song_id: "SNG0026"},
  {
    $inc: {play_count: 1},
    $set: {last_played: new Date()},
    $push: {
      recent_plays: {
        user_id: "user_9",
        played_at: new Date(),
        duration: 180
      }
    }
  }
)

// 12. READ: most popular music genres
// Objective: to study what genres are the most listened (therefore, popular) amongst users
db.users.aggregate([
  {
    $match: {
      "preferences.favorite_genres": {$exists: true, $ne: []}
    }
  },
  {
    $unwind: "$preferences.favorite_genres"
  },
  {
    $group: {
      _id: "$preferences.favorite_genres",
      user_count: {$sum: 1},
      premium_users: {
        $sum: {
          $cond: [{$eq: ["$subscription.type", "premium"]}, 1, 0]
        }
      }
    }
  },
  {
    $sort: {user_count: -1}
  },
  {
    $project: {
      _id: 0,
      genre: "$_id",
      user_count: 1,
      premium_users: 1,
      percentage_premium: {
        $multiply: [
          {$divide: ["$premium_users", "$user_count"]},
          100
        ]
      }
    }
  }
])

// 13. DELETE: removal of inactive users
// Objective: eliminate users who haven't logged in for >6 months and who don't have any activity
db.users.deleteMany({
  last_login: { 
    $lt: new Date(Date.now() - 180 * 24 * 60 * 60 * 1000) 
  },
  "stats.play_count": {$lt: 10},
  "stats.playlist_count": 0
})

// 14. CREATE: addition of a new song into the system
// Objective: to insert a new song into 'songs' collection
db.songs.insertOne({
  song_id: "song_" + Date.now(),
  title: "New Song Title",
  artist: "Artist Name",
  album: "Album Name",
  genre: "Pop",
  duration: 210, // in seconds
  release_date: new Date(),
  play_count: 0,
  popularity: 0,
  explicit: false,
  tags: ["new", "pop", "2024"],
  added_by: "admin",
  added_date: new Date()
})

// 15. READ: Songs organised by genres with statistics on plays
// Objective: To show a song's play count and average plays per genre
db.songs.aggregate([
  {
    $group: {
      _id: "$genre",
      song_count: {$sum: 1},
      avg_plays: {$avg: "$play_count"},
      total_plays: {$sum: "$play_count"}
    }
  },
  {
    $sort: { total_plays: -1 }
  },
  {
    $project: {
      genre: "$_id",
      song_count: 1,
      avg_plays: {$round: ["$avg_plays", 2]},
      total_plays: 1
    }
  }
])















   

  