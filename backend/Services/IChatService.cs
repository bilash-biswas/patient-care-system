using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using PatientManagementSystem.DTOs;

namespace PatientManagementSystem.Services
{
    public interface IChatService
    {
        Task<(IEnumerable<ChatUserDto> Users, int TotalCount)> GetDirectoryAsync(
            string? role,
            string? search,
            bool? isActive,
            int page,
            int pageSize,
            Guid currentUserId,
            string currentUserRole);

        Task<(IEnumerable<ChatMessageDto> Messages, int TotalCount)> GetMessagesAsync(
            Guid currentUserId,
            Guid otherUserId,
            int page,
            int pageSize);

        Task<IEnumerable<ChatUserDto>> GetConversationsAsync(Guid currentUserId);

        Task<ChatMessageDto> SaveMessageAsync(Guid senderId, Guid receiverId, string content);

        Task<bool> IsChatAllowedAsync(Guid userAId, Guid userBId);
    }
}
