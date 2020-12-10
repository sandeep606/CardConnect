var exec = require('cordova/exec');



module.exports.initialisePayment = function (arg0, success, error) {
    exec(success, error, 'CardConnectMobileiOS', 'initialisePayment', [arg0]);
};

module.exports.cancelPayment = function (arg0, success, error) {
    exec(success, error, 'CardConnectMobileiOS', 'cancelPayment', [arg0]);
};

module.exports.removePaymentView = function (arg0, success, error) {
    exec(success, error, 'CardConnectMobileiOS', 'removePaymentView', [arg0]);
};