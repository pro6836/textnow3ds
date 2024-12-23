--https://github.com/lovebrew/lovepotion for lovebrew/lovepotion, required for now
-- main.lua
local http = require("socket.http")
local ltn12 = require("ltn12")

local IP = "<IP>:5000" -- Set your IP address here
local number = "" -- Default number variable
local messages = {} -- Table to store messages
local inputText = "" -- Text input for sending messages
local state = "select"

function love.load()
    love.graphics.setFont(love.graphics.newFont(14))
end

function love.update(dt)
    --Do Nothing
end

function love.draw(screen)
    if screen ~= "bottom" then
        -- render top screen
        love.graphics.clear(0.2, 0.2, 0.2) -- Clear screen with gray color
        love.graphics.printf("TNDS - TextNowDS - X to exit app", 10, 10, love.graphics.getWidth() - 20)
    
        -- Display messages on the top screen
        for i, msg in ipairs(messages) do
            love.graphics.printf(msg, 10, 30 + (i * 20), love.graphics.getWidth() - 20)
        end
    end
    
end

function love.gamepadpressed(js, key)
    if key == "b" then
        if state == "select" then
            love.keyboard.setTextInput(true)
        else
            table.insert(messages, "ERROR => Restart App To Reselect Number")
        end
    elseif key == "x" then
        receiveMessages()
    elseif key == "a" then
        if state == "chat" then
            love.keyboard.setTextInput(true)
        else
            table.insert(messages, "ERROR => Select Number Before Chatting")
        end
    elseif key == "y" then
        table.insert(messages, "ERROR => Photos aren't implemented yet...")
    elseif key == "start" then
        for i,v in ipairs(messages) do table.remove(messages, i) end
    end
end

function love.textinput(text)
    inputText = text
    handleText()
end

function takePhoto()
    --TODO: add takePhoto, Photo handler on server, and client <-> server communication for Photos.
end

function handleText()
    if state == "chat" then
        sendMessage(inputText)
        table.insert(messages, "YOU => " .. inputText)
    elseif state == "select" then
        table.insert(messages, "Select Number => " .. inputText)
        number = inputText
        state = "chat"
    else
        table.insert(messages, "ERROR => Invalid app state: " .. state)
    end
end

function sendMessage(text)
    local response_body = {}
    local res, code = http.request{
        url = string.format("http://%s/send?text=%s&numb=%s", IP, text, number),
        sink = ltn12.sink.table(response_body)
    }
    if code == 200 then
        --Success!
    else
        table.insert(messages, "Error sending message: " .. code)
    end
end

function receiveMessages()
    if state == "chat" then
        local response_body = {}
        local res, code = http.request{
            url = string.format("http://%s/get?numb=%s", IP, number),
            sink = ltn12.sink.table(response_body)
        }
        if code == 200 then
            local receivedMessage = table.concat(response_body)
            if receivedMessage ~= "" and receivedMessage ~= "1upd" then
                table.insert(messages, "OTHER => " .. receivedMessage)
            end
        else
            table.insert(messages, "Error receiving message: " .. code)
            table.insert(messages, "Check that the PYTHON server is running")
            state = "error"
        end
    end
end
