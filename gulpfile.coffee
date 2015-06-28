lr = require('tiny-lr')
gulp = require('gulp')
jade = require('gulp-jade')
sass = require('gulp-ruby-sass')
livereload = require('gulp-livereload')
csso = require('gulp-csso')
imagemin = require('gulp-imagemin')
uglify = require('gulp-uglify')
concat = require('gulp-concat')
connect = require('connect')
rename = require('gulp-rename')
coffee = require('gulp-coffee')
filter = require('gulp-filter')
scss = require('gulp-scss')
serveStatic = require('serve-static')
clean = require('gulp-clean')
mainBowerFiles = require('main-bower-files')
es = require('event-stream')

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

gulp.task 'vendor:fonts', ->
  vendors = mainBowerFiles()
  gulp.src(vendors) 
  .pipe(filter(['*.eot', '*.ttf', '*.woff', '*.woff2']))
  .pipe(gulp.dest('./public/fonts'));

gulp.task 'fonts', ->
  gulp.src ['./assets/fonts/*']
  .pipe(filter(['*.eot', '*.ttf', '*.woff', '*.woff2']))
  .pipe(gulp.dest('./public/fonts'));

server = lr();

gulp.task 'jade', ->
  gulp.src ['./assets/template/*.jade', '!./assets/template/_*.jade']
  .pipe jade
    pretty: true
  .on('error', console.log)
  .pipe(gulp.dest('./public/'))
  .pipe(livereload(server))


gulp.task 'js', ->
  es.concat(
    gulp.src('./assets/javascript/**/*.coffee')
    .pipe(coffee())
    .on('error', console.log),
    gulp.src('./assets/javascript/**/*.js')
  ).pipe(concat('index.js')) # Собираем все JS, кроме тех которые находятся в ./assets/js/vendor/**
  .pipe(gulp.dest('./public/js'))
  .pipe(livereload(server)); # даем команду на перезагрузку страницы

gulp.task 'scss', ->
  gulp.src('./assets/css/**/*.scss')
  .pipe(scss())
  .on('error', console.log)
  .pipe(concat('style.css'))
  .pipe(gulp.dest('public/css'))
  .pipe(livereload(server))


gulp.task 'clean', ->
  # does not run synchroniously and blocks stream for some reason, investigate further
  # gulp.src('./public/', read: false)
  # .pipe(clean())

gulp.task 'images', ->
  gulp.src('./assets/images/**/*', base: './assets/images')
  .on('error', console.log)
  .pipe(gulp.dest('public/images'))

# Локальный сервер для разработки
gulp.task 'http-server', ->
  connect()
  .use(require('connect-livereload')())
  .use(serveStatic('./public'))
  .listen '9000'
  console.log('Server listening on http://localhost:9000');


# gulp.task 'watch', ['clean', 'vendor:js', 'vendor:css', 'vendor:fonts', 'fonts', 'images', 'jade', 'coffee', 'scss', 'http-server'], ->
gulp.task 'watch', ['clean', 'fonts', 'images', 'jade', 'js', 'scss', 'http-server'], ->

  # live reload
  server.listen 35729, (err) ->
    return console.log(err) if err
    gulp.watch 'assets/css/**/*.scss', ['scss']
    gulp.watch 'assets/template/**/*.jade', ['jade']
    gulp.watch 'assets/javascript/**/*.coffee', ['js']
    gulp.watch 'assets/javascript/**/*.js', ['js']