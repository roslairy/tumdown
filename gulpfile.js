/**
 * Configurations
 */

var coffeeSrcs = [
  {
    name: "data",
    srcs: ["data.coffee"]
  },

  {
      name: "popup",
      srcs: ["data.coffee", "popup.coffee"]
  },

  {
    name: "background",
    srcs: ["data.coffee", "downloader.coffee"]
  },

  {
    name: "content",
    srcs: ["content.coffee"]
  }
];
var coffeeDestDir = './extension/js/'

var htmlDir = './src/html/';
var htmlDestDir = './extension/html/';

var cssDir = './src/css/';
var cssDestDir = './extension/css/';

var jsDir = './src/js/';
var jsDestDir = './extension/js/';

var imgDir = './src/img/';
var imgDestDir = './extension/img/';

var copyFiles = ['./src/manifest.json'];
var copyDestDir = './extension/';

/**
 * Fix
 */

var addPrefix = function (arr, prefix) {
    var i = -1;
    while (++i < arr.length){
        arr[i] = prefix + arr[i];
    }
};

coffeeSrcs.forEach(function (elem){
  addPrefix(elem.srcs, './src/coffee/');
});

/**
 * Task
 */

var gulp    = require('gulp');
var concat  = require('gulp-concat');
var uglify=require("gulp-uglify");
var coffee = require('gulp-coffee');
var pug = require('gulp-pug');
var minifycss = require('gulp-minify-css');
var watch  = require('gulp-watch');
var gutil = require('gulp-util');

gulp.task('coffee', function() {
  coffeeSrcs.forEach(function (elem){
    gulp.src(elem.srcs)
        .pipe(concat(elem.name + '.coffee'))
        .pipe(coffee())
        .on('error', function(err) {
            gutil.log('coffee error: ', err.message);
            this.end();
        })
        //.pipe(uglify())
        .pipe(gulp.dest(coffeeDestDir));
  });
});

// gulp.task('pug', function buildHTML() {
//   gulp.src(pugDir + '*.pug')
//       .pipe(pug())
//       .pipe(gulp.dest(pugDestDir));
// });

gulp.task('html', function() {
    return gulp.src(htmlDir + '*')
        .pipe(gulp.dest(htmlDestDir));
});

gulp.task('js', function() {
    return gulp.src(jsDir + '*')
        .pipe(gulp.dest(jsDestDir));
});

gulp.task('css', function() {
  return gulp.src(cssDir + '*')
      //.pipe(concat('LifeFrame.min.css'))
      //.pipe(minifycss())
      .pipe(gulp.dest(cssDestDir));
});

gulp.task('img', function() {
    return gulp.src(imgDir + '*')
        .pipe(gulp.dest(imgDestDir));
});

gulp.task('copy', function() {
    return gulp.src(copyFiles)
        .pipe(gulp.dest(copyDestDir));
});

gulp.task('default', ['coffee', 'html', 'js', 'css', 'img', 'copy']);

gulp.task('watch', function() {
    gulp.watch([ 'src/**'], ['default']);
});
