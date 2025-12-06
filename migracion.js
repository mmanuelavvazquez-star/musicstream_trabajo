
//crear archivos

psql -h appserver.alunos.di.fc.ul.pt -U bd030 -d bd030 -c "COPY (
  SELECT row_to_json(t) 
  FROM (
    SELECT 
      playback_id,
      user_id,
      song_id,
      device_id,
      playlist_id,
      play_date,
      duration_played,
      completed
    FROM bd030_schema21.play_history
  ) t
) TO STDOUT" > play_history.json



psql -h appserver.alunos.di.fc.ul.pt -U bd030 -d bd030 -c 'COPY (
  SELECT row_to_json(t) 
  FROM (
    SELECT 
      playlist_id,
      playlist_title,
      playlist_description,
      total_songs,
      playlist_duration,
      cover_photo,
      user_id
    FROM bd030_schema21.playlist
  ) t
) TO STDOUT' > playlist.json



psql -h appserver.alunos.di.fc.ul.pt -U bd030 -d bd030 -c 'COPY (
  SELECT row_to_json(t)
  FROM (
    SELECT 
      follower_id,
      followed_id
    FROM bd030_schema21.follows
  ) t
) TO STDOUT' > follows.json


//IMPORTAR
//"C:\Users\Manuela\Downloads\mongodb-database-tools-windows-x86_64-100.13.0\mongodb-database
//-tools-windows-x86_64-100.13.0\bin\mongoimport.exe" --uri "mongodb://bd030:bd030@appserver.
//alunos.di.fc.ul.pt:27017/bd030?authSource=bd030" --collection play_history --file "C:\Users
//\Manuela\play_history.json"

//"C:\Users\Manuela\Downloads\mongodb-database-tools-windows-x86_64-100.13.0\mongodb-database-
//tools-windows-x86_64-100.13.0\bin\mongoimport.exe" --uri "mongodb://bd030:bd030@appserver.
//alunos.di.fc.ul.pt:27017/bd030?authSource=bd030" --collection follows --file "C:\Users\Manuela
//\follows_mongo.json"

//"C:\Users\Manuela\Downloads\mongodb-database-tools-windows-x86_64-100.13.0\mongodb-database-tools
//-windows-x86_64-100.13.0\bin\mongoimport.exe" --uri "mongodb://bd030:bd030@appserver.alunos.di.fc.
//ul.pt:27017/bd030?authSource=bd030" --collection playlist --file "C:\Users\Manuela\playlist.json"




