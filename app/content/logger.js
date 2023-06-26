const winston = require('winston');
require('winston-daily-rotate-file');

const { combine, timestamp, printf, colorize } = winston.format

const logDir = '../logs';

const level = () => {
    const env = process.env.NODE_ENV || 'development'
    const isDevelopment = env === 'development'
    return isDevelopment ? 'debug' : 'warn'
}

const colors = {
    error: 'red',
    warn: 'yellow',
    info: 'green',
    http: 'magenta',
    debug: 'blue',
}

winston.addColors(colors);

const format = combine(
    timestamp({ format: ' YYYY-MM-DD HH:mm:ss ||' }),    
    printf(
        (info) => `${info.timestamp} [ ${info.level} ] ▶ ${info.message}`,
    ),
)

const logger = winston.createLogger({
    format,
    level: level(),
    transports: [
        new winston.transports.DailyRotateFile({
            level: 'info',
            datePattern: 'YYYY-MM-DD',
            dirname: logDir,
            filename: `%DATE%.log`,
            zippedArchive: true,	
            handleExceptions: true,
            maxFiles: 30,  
        }),
        new winston.transports.DailyRotateFile({
            level: 'error',
            datePattern: 'YYYY-MM-DD',
            dirname: logDir,
            filename: `%DATE%.error.log`,
            zippedArchive: true,
            maxFiles: 30,
        }),
        new winston.transports.Console({
            handleExceptions: true,
            format: combine(
                colorize({ all: true })
            )
        })
    ]
});

module.exports = logger;