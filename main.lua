-- Инициализируем переменные
local platform
local balls
local blocks
local score = 0
local highscore = 0
local colors = { -- Цвета блоков
  {255, 0, 0},   -- Красный
  {0, 255, 0},   -- Зеленый
  {0, 0, 255},   -- Синий
}
local powerups = { -- Типы улучшений
  "увеличение платформы",
  "уменьшение платформы",
  "увеличение скорости шарика",
  "уменьшение скорости шарика",
}

-- Загрузка игры
function love.load()
  love.window.setTitle("Игра блоки")
  love.window.setMode(800, 600, { resizable = false })
  
  platform = {
    x = love.graphics.getWidth()/2 - 50,  -- Начальные координаты платформы
    y = love.graphics.getHeight() - 20,
    width = 100,
    height = 10,
    speed = 500
  }
  
  balls = {
    {
      x = love.graphics.getWidth()/2,  -- Начальные координаты шарика
      y = love.graphics.getHeight()/2,
      radius = 10,
      dx = 200 + math.random(0, 50),
      dy = -200 - math.random(0, 50)
    }
  }
  
  blocks = {}
  local blockWidth = 60
  local blockHeight = 20
  local numRows = 3
  local numCols = love.graphics.getWidth() / (blockWidth * 1.1)
  
  for row = 1, numRows do
    for col = 1, numCols do
        print(colors[row])
      local block = {
        x = (col-1) * (blockWidth + 5),
        y = (row-1) * (blockHeight + 5),
        width = blockWidth,
        height = blockHeight,
        color = colors[row],
      }
      block.powerup = (math.random(1,5) == 1) and true or false
      table.insert(blocks, block)
    end
  end
end

-- Обновление
function love.update(dt)
  -- Управление платформой
  if love.keyboard.isDown("left") then
    platform.x = platform.x - platform.speed * dt
  elseif love.keyboard.isDown("right") then
    platform.x = platform.x + platform.speed * dt
  end
  
  -- Обновление координат всех шариков
  for i, ball in ipairs(balls) do
    -- Обработка столкновения шарика с платформой
    if ball.y + ball.radius >= platform.y and
       ball.x + ball.radius >= platform.x and
       ball.x - ball.radius <= platform.x + platform.width then
      ball.dy = -ball.dy
    end
    
    -- Обработка столкновения шарика со блоками
    for j, block in ipairs(blocks) do
      if ball.x + ball.radius >= block.x and
         ball.x - ball.radius <= block.x + block.width and
         ball.y + ball.radius >= block.y and
         ball.y - ball.radius <= block.y + block.height then
        table.remove(blocks, j)
        ball.dy = -ball.dy
        score = score + 1
        
        -- Появление нового шарика при получении улучшения
        if block.powerup then
          local newBall = {
            x = ball.x,
            y = ball.y,
            radius = ball.radius,
            dx = -ball.dx,
            dy = -ball.dy
          }
          table.insert(balls, newBall)
        end
        
        break
      end
    end
    
    -- Обновление координат шарика
    ball.x = ball.x + ball.dx * dt
    ball.y = ball.y + ball.dy * dt
    
    -- Обработка столкновения шарика со стенками
    if ball.x - ball.radius < 0 or ball.x + ball.radius > love.graphics.getWidth() then
      ball.dx = -ball.dx
    end
    
    if ball.y - ball.radius < 0 then
      ball.dy = -ball.dy
    end
    
    -- Удаление шарика при падении
    if ball.y + ball.radius > love.graphics.getHeight() then
      table.remove(balls, i)
      
      if #balls == 0 then
        gameover = true
        highscore = math.max(highscore, score)
      end
    end
  end
end

-- Перерисовка экрана
function love.draw()
  -- Отрисовка платформы
  love.graphics.rectangle("fill", platform.x, platform.y, platform.width, platform.height)
  
  -- Отрисовка блоков
  for i, block in ipairs(blocks) do
    love.graphics.setColor(block.color)
    love.graphics.rectangle("fill", block.x, block.y, block.width, block.height)
  end
  
  -- Отрисовка шариков
  for i, ball in ipairs(balls) do
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("fill", ball.x, ball.y, ball.radius)
  end
  

    -- Отрисовка счета
  love.graphics.print("Score: " .. score, 10, 10 + 70)
  love.graphics.print("Max Score: " .. highscore, 10, 30 + 70)
  
  -- Отрисовка кнопки перезапуска игры
  if gameover then
    love.graphics.print("Game Over!", love.graphics.getWidth()/2 - 70, love.graphics.getHeight()/2 - 20)
    love.graphics.print("Press 'R', to restart", love.graphics.getWidth()/2 - 110, love.graphics.getHeight()/2)
  end

end

-- Перезагрузка игры
function resetGame()
    gameover = false
  platform.x = love.graphics.getWidth()/2 - 50
  balls = {
    {
      x = love.graphics.getWidth()/2,
      y = love.graphics.getHeight()/2,
      radius = 10,
      dx = 200,
      dy = -200
    }
  }
  score = 0
end

function love.keypressed(key)
  -- Выход из игры по нажатию клавиши Escape
  if key == "r" then
    resetGame()
  end
end