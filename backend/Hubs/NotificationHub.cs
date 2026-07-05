using Microsoft.AspNetCore.SignalR;

namespace PatientManagementSystem.Hubs
{
    public class NotificationHub : Hub
    {
        public async Task SendNotification(string userId, string message)
        {
            await Clients.User(userId).SendAsync("ReceiveNotification", message);
        }

        public async Task BroadcastNotification(string message)
        {
            await Clients.All.SendAsync("ReceiveBroadcast", message);
        }
    }
}
