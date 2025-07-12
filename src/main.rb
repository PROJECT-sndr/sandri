require 'dotenv/load'
require 'discordrb'

token = ENV['TOKEN']
prefix = ENV['PREFIX']
client_id = ENV['CLIENT_ID']

sandri = Discordrb::Commands::CommandBot.new token: token, client_id: client_id, prefix: prefix

if token.nil? || token.empty?
  puts "TOKEN não definido. Verifique a variável no arquivo .env"
  exit
end

sandri.ready do
  puts "-"*100
  puts "SANDRI INICIALIZADO - 🟢 [STATUS: ON]"
  puts "-"*100
  puts "Bot inicializado com o prefixo: #{prefix}"
  puts "Bot conectado como #{sandri.profile.username}"
  puts "ID do bot: #{sandri.profile.id}"
  puts "Servidores conectados: #{sandri.servers.count}"
  puts "-"*100
end

sandri.command(:say, description: "Sandri repeats what you say!") do |event, *args|
    if (args.empty?)
      event.respond "Uso correto: ``#{prefix}say <*args>``"
      return
    end
    event.respond args.join(" ").delete('"')
end

sandri.command(:ping, description: "Pong!") do |event|
  event.respond 'Pong!'
end

sandri.command(:calc, description: "Sandri calculates your math! (Available operations: '+', '-', '*', '/', '%' )") do |event, n1, operation, n2|
  if (n1.nil? || operation.nil? || n2.nil?)
    event.respond "Uso correto: ``#{prefix}calc <n1> <operation> <n2>``"
    return
  end
  
  is_float1 = n1.include?('.')
  is_float2 = n2.include?('.')
  
  if (is_float1 || is_float2)
    num1 = n1.to_f
    num2 = n2.to_f
    
    case operation
    when "+"
      event.respond "#{num1} + #{num2} = #{num1 + num2}"
    when "-" 
      event.respond "#{num1} - #{num2} = #{num1 - num2}"
    when "*"
      event.respond "#{num1} * #{num2} = #{num1 * num2}"
    when "/"
      if num2.zero?
        event.respond "❌ **Erro**: divisão por zero não é permitida"
      else
        event.respond "#{num1} / #{num2} = #{num1 / num2}"
      end
    when "%"
      if num2.zero?
        event.respond "❌ **Erro**: módulo por zero não é permitido"
      else
        event.respond "#{num1} % #{num2} = #{num1 % num2}"
      end
    else
      event.respond "Operação inválida. Use +, -, *, / ou %"
    end
  else
    begin
      num1 = Integer(n1)
      num2 = Integer(n2)
      
      if (num1 && num2 == 0)
        if (operation == '+')
          event.respond "#{num1} + #{num2} = 2 - (Segundo o Angola Institute of Memes, AIM)"
        end
      end
        
      case operation
      when "+"
        event.respond "#{num1} + #{num2} = #{num1 + num2}"
      when "-"
        event.respond "#{num1} - #{num2} = #{num1 - num2}"
      when "*"
        event.respond "#{num1} * #{num2} = #{num1 * num2}"
      when "/"
        if num2.zero?
          event.respond "❌ **Erro**: divisão por zero não é permitida"
        else
          event.respond "#{num1} / #{num2} = #{num1.to_f / num2}"
        end
      when "%" 
        if num2.zero?
          event.respond "❌ **Erro**: módulo por zero não é permitido"
        else
          event.respond "#{num1} % #{num2} = #{num1 % num2}"
        end
      else
        event.respond "Operação inválida. Use +, -, *, / ou %"
      end
    rescue ArgumentError
      event.respond "Números inválidos. Certifique-se de usar números válidos. (OBS: Não use ',' para números decimais, use o '.'!)"
    end
  end
end

sandri.command(:clear, min_args: 0, max_args: 1, description: "Limpa uma quantidade específica de mensagens do chat") do |event, count|
  unless event.user.permission?(:administrator) || event.user.permission?(:manage_messages)
    event.respond "``WARNING:`` Você não tem permissão para limpar mensagens #{event.author.username}"
    next
  end

  count = (count || 10).to_i

  begin 
    messages = event.channel.history(count + 1)
    if messages.empty?
      event.respond "``WARNING:`` Não há mensagens para apagar"
      next
    end

    confirmation = event.respond "🗑️ Apagando #{messages.size - 1} mensagens..."
    deleted_count = event.channel.delete_messages(messages)
    temp_message = event.respond "✅ **#{deleted_count - 1}** mensagens foram apagadas."
  rescue Discordrb::Errors::NoPermission
    event.respond "❌ **Erro**: Eu não tenho permissão para apagar mensagens neste canal."
  rescue => e 
    "❌ **Erro**: Eu não tenho permissão para apagar mensagens neste canal."
  end
end

sandri.run
