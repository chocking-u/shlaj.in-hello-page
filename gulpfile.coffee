lr = require('tiny-lr') # Минивебсервер для livereload
gulp = require('gulp') # Сообственно Gulp JS
jade = require('gulp-jade') # Плагин для Jade
sass = require('gulp-ruby-sass') # Плагин для Stylus
livereload = require('gulp-livereload') # Livereload для Gulp
csso = require('gulp-csso') # Минификация CSS
imagemin = require('gulp-imagemin') # Минификация изображений
uglify = require('gulp-uglify') # Минификация JS
concat = require('gulp-concat') # Склейка файлов
connect = require('connect') # Webserver
rename = require('gulp-rename')
coffee = require('gulp-coffee')
filter = require('gulp-filter')
scss = require('gulp-scss')
serveStatic = require('serve-static')

mainBowerFiles = require('main-bower-files')
 
gulp.task "vendor:js", ->
  vendors = mainBowerFiles()
  gulp.src(vendors)
  .pipe(filter('**.js'))
  .pipe(concat('vendor.js'))
  .pipe(gulp.dest('public/js'))

gulp.task "vendor:css", ->
  vendors = mainBowerFiles()
  gulp.src(vendors)
  .pipe(filter('**.css'))
  .pipe(concat('vendor.css'))
  .pipe(gulp.dest('public/css'))  

server = lr();

gulp.task 'jade', ->
  gulp.src ['./assets/template/*.jade', '!./assets/template/_*.jade']
  .pipe jade
    pretty: true
  .on('error', console.log)
  .pipe(gulp.dest('./public/'))
  .pipe(livereload(server))


gulp.task 'coffee', ->
  a = gulp.src('./assets/javascript/**/*.coffee')
  .pipe(coffee())
  .on('error', console.log)
  .pipe(concat('index.js')) # Собираем все JS, кроме тех которые находятся в ./assets/js/vendor/**
  .pipe(gulp.dest('./public/js'))
  .pipe(livereload(server)); # даем команду на перезагрузку страницы

gulp.task 'scss', ->
  gulp.src('./assets/javascript/**/*.scss')
  .pipe(scss())
  .on('error', console.log)
  .pipe(concat('index.css'))
  .pipe(livereload(server))


# Локальный сервер для разработки
gulp.task 'http-server', ->
  connect()
  .use(require('connect-livereload')())
  .use(serveStatic('./public'))
  .listen '9000'
  console.log('Server listening on http://localhost:9000');


gulp.task 'watch', ->
  # Предварительная сборка проекта
  gulp.run('vendor:js');
  gulp.run('vendor:css');
  gulp.run('jade');
  gulp.run('coffee');
  gulp.run('scss');

  # live reload
  server.listen 35729, (err) ->
    return console.log(err) if err

    gulp.watch 'assets/css/**/*.scss', ->
      gulp.run('scss');
    
    gulp.watch 'assets/template/**/*.jade', ->
      gulp.run('jade');
    
    gulp.watch 'assets/javascript/**/*.coffee', ->
      gulp.run('coffee');
    
  gulp.run('http-server');