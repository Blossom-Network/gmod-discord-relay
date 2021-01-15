const Discord = require('discord.js');
const WebSocket = require('ws');
const config = require('./configuration/config.json');

const client = new Discord.Client();
const wss = new WebSocket.Server({
  port: 8080
});

client.on('message', (msg) => {
    if (msg.channel.id == config.channelID && msg.guild.id == config.guildID && !msg.author.bot) {
        data = {
            "username": msg.member.user.username,
            "text": msg.content
        }

        if(msg.content.startsWith(config.prefix)) {
            data["type"] = "command";
            data.text = data.text.split(' ')[0];
            data.text = data.text.substring(config.prefix.length);
        } else {
            data["type"] = "message";
        }

        wss.clients.forEach(function each(client) {
            if (client.readyState === WebSocket.OPEN) {
                client.send(JSON.stringify(data));
            }
        });
    }
})

wss.on('connection', function connection(ws) {
    ws.on('message', function incoming(msg) {
        channel = client.guilds.cache.get(config.guildID).channels.cache.get(config.channelID);
        msg = JSON.parse(msg);

        console.log(msg);

        if(msg.type == "text") channel.send(msg.data);
        if(msg.type == "embed") {
            let embed = new Discord.MessageEmbed().setColor("#2f2f2f").setTimestamp().setFooter("Blossom Network").setTitle(msg.data.header);
            for (const field in msg.data.fields) {
                let name = field.charAt(0).toUpperCase() + field.slice(1);
                embed.addField(name, msg.data.fields[field], true)
            }
            channel.send(embed);
        }
    });
});

client.login(config.token);