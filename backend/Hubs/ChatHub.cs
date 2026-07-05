using Microsoft.AspNetCore.SignalR;
using PatientManagementSystem.Services;
using PatientManagementSystem.Data;
using System;
using System.Security.Claims;
using System.Threading.Tasks;

namespace PatientManagementSystem.Hubs
{
    public class ChatHub : Hub
    {
        private readonly IChatService _chatService;
        private readonly ApplicationDbContext _context;

        public ChatHub(IChatService chatService, ApplicationDbContext context)
        {
            _chatService = chatService;
            _context = context;
        }

        public async Task SendMessage(string receiverId, string content)
        {
            var senderIdClaim = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(senderIdClaim) || !Guid.TryParse(senderIdClaim, out var senderId))
                return;

            if (!Guid.TryParse(receiverId, out var receiverIdGuid))
                return;

            try
            {
                var message = await _chatService.SaveMessageAsync(senderId, receiverIdGuid, content);
                var sender = await _context.Users.FindAsync(senderId);
                var senderName = sender != null ? $"{sender.FirstName} {sender.LastName}".Trim() : "Someone";

                await Clients.User(receiverId).SendAsync("ReceiveMessage", new
                {
                    id = message.Id,
                    senderId = message.SenderId,
                    senderName = senderName,
                    receiverId = message.ReceiverId,
                    content = message.Content,
                    sentAt = message.SentAt,
                    isRead = message.IsRead
                });
            }
            catch (Exception)
            {
                // Fail silently or notify sender of authorization/validation issue
            }
        }
    }
}
