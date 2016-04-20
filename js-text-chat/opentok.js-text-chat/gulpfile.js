var gulp = require('gulp');
var concat = require('gulp-concat');
var importCss = require('gulp-import-css');
var uglify = require('gulp-uglify');
inlineCss = require('gulp-inline-css');

gulp.task('js', function () {
  return gulp.src('src/text-chat-acc-pack.js')
    .pipe(concat('text-chat-acc-pack.js'))
    .pipe(uglify())
    .pipe(gulp.dest('dist'));
});


gulp.task('css', function () {
  return gulp.src('css/theme.css')
    .pipe(importCss())
    .pipe(gulp.dest('dist'));
});

gulp.task('dist', ['js', 'css']);
