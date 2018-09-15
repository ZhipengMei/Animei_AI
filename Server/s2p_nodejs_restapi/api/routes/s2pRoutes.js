'use strict';
module.exports = function(app) {
  var s2p = require('../controllers/s2pController');

  // s2p Routes
  app.route('/tasks')
    .get(s2p.list_all_tasks)
    .post(s2p.create_a_task);


  app.route('/tasks/:taskId')
    .get(s2p.read_a_task)
    .put(s2p.update_a_task)
    .delete(s2p.delete_a_task);
};
