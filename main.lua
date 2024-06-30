function love.load()
    initializeGame()
end

function initializeGame()
    -- Параметры блока
    blockWidth = 100
    blockHeight = 30
    blocks = {}
    fallingBlocks = {}
    clouds = {}
    score = 0

    -- Первый блок в центре
    local startX = (love.graphics.getWidth() - blockWidth) / 2
    local startY = love.graphics.getHeight() - blockHeight
    table.insert(blocks, {x = startX, y = startY, width = blockWidth, height = blockHeight})

    -- Перемещение нового блока
    newBlock = {x = 0, y = startY - blockHeight, width = blockWidth, height = blockHeight}
    direction = "right"
    speed = 200
    gameOver = false

    -- Цвет фона (небо)
    skyColor = {0.529, 0.808, 0.922}

    -- Инициализация облаков
    for i = 1, 5 do
        local cloud = {
            x = love.math.random(0, love.graphics.getWidth()),
            y = love.math.random(0, love.graphics.getHeight() / 2),
            speed = love.math.random(20, 50),
            width = love.math.random(50, 100),
            height = love.math.random(20, 50)
        }
        table.insert(clouds, cloud)
    end
end

function love.update(dt)
    if gameOver then return end
    
    -- Движение нового блока
    if direction == "right" then
        newBlock.x = newBlock.x + speed * dt
        if newBlock.x + newBlock.width > love.graphics.getWidth() then
            direction = "left"
        end
    else
        newBlock.x = newBlock.x - speed * dt
        if newBlock.x < 0 then
            direction = "right"
        end
    end
    
    -- Обновление позиции падающих обрезков блоков
    for i = #fallingBlocks, 1, -1 do
        local block = fallingBlocks[i]
        block.y = block.y + 300 * dt
        if block.y > love.graphics.getHeight() then
            table.remove(fallingBlocks, i)
        end
    end

    -- Обновление позиции облаков
    for _, cloud in ipairs(clouds) do
        cloud.x = cloud.x + cloud.speed * dt
        if cloud.x > love.graphics.getWidth() then
            cloud.x = -cloud.width
        end
    end
end

function love.keypressed(key)
    if gameOver then
        if key == "r" then
            initializeGame()
        end
        return
    end
    
    if key == "space" then
        -- Проверка попадания
        local lastBlock = blocks[#blocks]
        if newBlock.x + newBlock.width < lastBlock.x or newBlock.x > lastBlock.x + lastBlock.width then
            -- Игра окончена
            gameOver = true
        else
            -- Обрезка блока по границам нижнего блока
            if newBlock.x < lastBlock.x then
                local cutBlock = {
                    x = newBlock.x,
                    y = newBlock.y,
                    width = lastBlock.x - newBlock.x,
                    height = newBlock.height
                }
                table.insert(fallingBlocks, cutBlock)
                
                newBlock.width = newBlock.width - cutBlock.width
                newBlock.x = lastBlock.x
            end
            if newBlock.x + newBlock.width > lastBlock.x + lastBlock.width then
                local cutBlock = {
                    x = lastBlock.x + lastBlock.width,
                    y = newBlock.y,
                    width = newBlock.x + newBlock.width - (lastBlock.x + lastBlock.width),
                    height = newBlock.height
                }
                table.insert(fallingBlocks, cutBlock)
                
                newBlock.width = newBlock.width - cutBlock.width
            end
            
            table.insert(blocks, {x = newBlock.x, y = newBlock.y, width = newBlock.width, height = newBlock.height})
            newBlock = {x = 0, y = newBlock.y - blockHeight, width = newBlock.width, height = blockHeight}
            score = score + 1
        end
    end
end

function drawBlockWithWindows(x, y, width, height)
    -- Рисуем блок
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", x, y, width, height)

    -- Рисуем окна
    love.graphics.setColor(1, 1, 0)
    local windowWidth = 10
    local windowHeight = 15
    local spaceBetweenWindows = 5
    local numWindows = math.floor((width - spaceBetweenWindows) / (windowWidth + spaceBetweenWindows))

    -- Центрирование окон
    local totalWindowsWidth = numWindows * windowWidth + (numWindows - 1) * spaceBetweenWindows
    local startX = x + (width - totalWindowsWidth) / 2

    for i = 1, numWindows do
        local windowX = startX + (i - 1) * (windowWidth + spaceBetweenWindows)
        local windowY = y + (height - windowHeight) / 2
        love.graphics.rectangle("fill", windowX, windowY, windowWidth, windowHeight)
    end
end

function love.draw()
    -- Рисуем фон (небо)
    love.graphics.clear(skyColor)

    -- Рисуем облака
    love.graphics.setColor(1, 1, 1)
    for _, cloud in ipairs(clouds) do
        love.graphics.rectangle("fill", cloud.x, cloud.y, cloud.width, cloud.height)
    end

    -- Рисуем блоки с окнами
    for _, block in ipairs(blocks) do
        drawBlockWithWindows(block.x, block.y, block.width, block.height)
    end

    -- Рисуем падающие обрезки блоков с окнами
    for _, block in ipairs(fallingBlocks) do
        drawBlockWithWindows(block.x, block.y, block.width, block.height)
    end

    -- Рисуем новый блок
    if not gameOver then
        drawBlockWithWindows(newBlock.x, newBlock.y, newBlock.width, newBlock.height)
    else
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("Game Over! Press 'R' to Restart", love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() / 2)
    end

    -- Рисуем счет игрока
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Score: " .. score, 10, 10)
end
