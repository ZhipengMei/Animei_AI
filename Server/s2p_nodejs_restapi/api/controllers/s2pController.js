'use strict';

// MARK - multer for image upload
var multer = require('multer');
var storage = multer.diskStorage({
    destination: function (req, file, cb) {
        //create new dir
        var fs = require('fs');
        var dir = './uploads/' + Date.now();
        if (!fs.existsSync(dir)){
          fs.mkdirSync(dir);
        }
        cb(null, dir + '/')
    },
    filename: function (req, file, cb) {
        // cb(null, file.fieldname + '-' + Date.now() + '.jpg')
        cb(null, file.originalname)
    }
});

var upload = multer({ storage: storage }).single('profileImage');
// ------------------------------

var mongoose = require('mongoose'),
  Task = mongoose.model('Tasks');

exports.list_all_tasks = function(req, res) {
  Task.find({}, function(err, task) {
    if (err)
      res.send(err);
    res.json(task);
  });
};


exports.create_a_task = function(req, res) {
  upload(req, res, function (err) {
      if (err) {
          // An error occurred when uploading
      }
      res.json({
          success: true,
          message: 'Image uploaded!',
          path: req.file.path, //important path
      });
      // console.log(req.file);
      // Everything went fine


      // // shell script execute python script to run AI models
      var shell = require('shelljs');
      shell.exec('./exe.sh ./' + req.file.path)

      // ----------------------------------------
      // Python scripts
      // var PythonShell = require('python-shell');
      // var pyshell = new PythonShell('s2p/s2p.py');
      // // sends a message to the Python script via stdin
      // pyshell.send(req.file.path);
      // // pyshell.send("lala");
      //
      //
      // pyshell.on('message', function (message) {
      //   // received a message sent from the Python script (a simple "print" statement)
      //   console.log(message);
      // });
      //
      // // end the input stream and allow the process to exit
      // pyshell.end(function (err,code,signal) {
      //   if (err) throw err;
      //   // console.log('The exit code was: ' + code);
      //   // console.log('The exit signal was: ' + signal);
      //   // console.log('finished');
      //   console.log('finished');
      // });
      // end testing
      // ----------------------------------------
  })
};

// exports.create_a_task = function(req, res) {
//   var new_task = new Task(req.body);
//   new_task.save(function(err, task) {
//     if (err)
//       res.send(err);
//     res.json(task);
//
    // ----------------------------------------
    // Python scripts
    // var PythonShell = require('python-shell');
    //
    // PythonShell.run('hwp.py', function (err) {
    //   if (err) throw err;
    //   console.log('finished');
    // });
    // ----------------------------------------
//   });
// };


exports.read_a_task = function(req, res) {
  Task.findById(req.params.taskId, function(err, task) {
    if (err)
      res.send(err);
    res.json(task);
  });
};


exports.update_a_task = function(req, res) {
  Task.findOneAndUpdate({_id: req.params.taskId}, req.body, {new: true}, function(err, task) {
    if (err)
      res.send(err);
    res.json(task);
  });
};


exports.delete_a_task = function(req, res) {


  Task.remove({
    _id: req.params.taskId
  }, function(err, task) {
    if (err)
      res.send(err);
    res.json({ message: 'Task successfully deleted' });
  });
};
