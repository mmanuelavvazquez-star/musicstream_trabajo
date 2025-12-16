//Indexes
//Preview: indexes are mechanisms that are used to accelerate the process of accessing data. By creating them, the search for information through queries can be optimized. For each of the structures we have created the two indexes we have considered most appropriate 

//USERS
db.users.createIndex({email: 1}, {unique : true}) //orders users' emails in ascending (A-Z) alphabetic order
db.users.createIndex({country: 1, age: 1}) //groups users by country and age, both in ascending order (A-> for countries, 1-9 age)
db.users.createIndex({nick: 1}); //enables quick username_based search

//SONGS
db.songs.createIndex({genre: 1, play_count: -1}) //index that organises songs alphabetically (A-Z) by genres first and for each genre, sorts them by play_count. This enables efficient ranking and discovery (of genres) features
db.songs.createIndex({artist: 1}) //divides songs alphabetically by artists. Useful for queries that involve artist-search function or an artist's discography

//PLAYLIST
db.playlist.createIndex({user_id: 1}) //groups playlists with their creators. Essential for user profile that shows "My playlists"

//PLAY_HISTORY
db.play_history.createIndex({user_id: 1, play_date: -1}) //optimizes retrieval of the user's listening history, core feature of the "recently played" section
db.play_history.createIndex({song_id: 1, play_date: -1}) //useful to analise song popularity over time (thus, to study the song's performance)
db.play_history.createIndex({completed: 1}); //filters playback records based on completion status, useful for determining whether listening sessions were finished or not

//FOLLOWS
db.follows.createIndex({followers: 1}) //efficient retrieval of a user's following list
db.follows.createIndex({following_users: 1}) //efficient retrieval of followed users by a user
db.follows.createIndex({ followers: 1, following_users: 1 }, {unique: true}); //this ensures users cannot follow a user more than once, preventing duplication
