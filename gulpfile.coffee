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
mainBowerFiles = require('main-bower-files')
es = require('event-stream')
purify = require('gulp-purifycss')
minifyCss = require('gulp-minify-css')


# I switched to a custom compile version of bootstrap, so I don't need vendor bower files.
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

gulp.task 'images', ->
  gulp.src('./assets/images/**/*', base: './assets/images')
  .on('error', console.log)
  .pipe(gulp.dest('public/images'))


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
  ).pipe(concat('index.js'))
  .pipe(gulp.dest('./public/js'))
  .pipe(livereload(server))

gulp.task 'scss', ->
  es.concat(
    gulp.src('./assets/css/**/*.scss')
    .pipe(scss())
    .on('error', console.log),
    gulp.src('./assets/css/**/*.css')
  )
  .pipe(concat('style.css'))
  .pipe(gulp.dest('public/css'))
  .pipe(livereload(server))

gulp.task 'http-server', ->
  connect()
  .use(require('connect-livereload')())
  .use(serveStatic('./public'))
  .listen '9000'
  console.log('Server listening on http://localhost:9000');

gulp.task 'css:production', ->
  # purify + compress
  gulp.src('./public/css/**/*.css')
  .pipe(concat('style.css'))
  .pipe(purify(['./public/**/*.js', './public/**/*.html']))
  .pipe(minifyCss({compatibility: 'ie8'}))
  .pipe(gulp.dest('./production/css'));

gulp.task 'js:production', ->
  gulp.src('./public/js/**/*.js')
  .on('error', console.log)
  .pipe(concat('index.js'))
  .pipe(uglify())
  .pipe(gulp.dest('./production/js'))

gulp.task 'images:production', ->
  gulp.src('./public/images/**/*', base: './public/images')
  .on('error', console.log)
  .pipe(gulp.dest('production/images'))

gulp.task 'fonts:production', ->
  gulp.src('./public/fonts/**/*', base: './public/fonts')
  .on('error', console.log)
  .pipe(gulp.dest('production/fonts'))

gulp.task 'compile:production', ['compile:development'], ->
  gulp.start ['css:production', 'js:production', 'images:production', 'fonts:production']

gulp.task 'compile:development', ['fonts', 'images', 'jade', 'js', 'scss']

gulp.task 'watch', ->
  gulp.start 'compile:development'
  gulp.start 'http-server' # live reload
  server.listen 35729, (err) ->
    return console.log(err) if err
    gulp.watch 'assets/css/**/*.scss', ['scss']
    gulp.watch 'assets/css/**/*.css', ['scss']
    gulp.watch 'assets/template/**/*.jade', ['jade']
    gulp.watch 'assets/javascript/**/*.coffee', ['js']
    gulp.watch 'assets/javascript/**/*.js', ['js']