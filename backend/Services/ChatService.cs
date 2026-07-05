using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PatientManagementSystem.Data;
using PatientManagementSystem.DTOs;
using PatientManagementSystem.Models;

namespace PatientManagementSystem.Services
{
    public class ChatService : IChatService
    {
        private readonly ApplicationDbContext _context;

        public ChatService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<(IEnumerable<ChatUserDto> Users, int TotalCount)> GetDirectoryAsync(
            string? role,
            string? search,
            bool? isActive,
            int page,
            int pageSize,
            Guid currentUserId,
            string currentUserRole)
        {
            IQueryable<User> query = _context.Users.Where(u => u.Id != currentUserId);

            if (currentUserRole == "Admin")
            {
                query = query.Where(u => u.Role == "Patient" || u.Role == "Doctor" || u.Role == "Nurse");
            }
            else if (currentUserRole == "Doctor")
            {
                query = query.Where(u => u.Role == "Nurse" || u.Role == "Patient");
            }
            else if (currentUserRole == "Patient")
            {
                query = query.Where(u => u.Role == "Doctor");
            }
            else if (currentUserRole == "Nurse")
            {
                query = query.Where(u => u.Role == "Doctor" || u.Role == "Patient");
            }
            else
            {
                return (Enumerable.Empty<ChatUserDto>(), 0);
            }

            if (!string.IsNullOrEmpty(role))
            {
                query = query.Where(u => u.Role == role);
            }

            if (isActive.HasValue)
            {
                query = query.Where(u => u.IsActive == isActive.Value);
            }

            if (!string.IsNullOrEmpty(search))
            {
                var lowerSearch = search.ToLower();
                query = query.Where(u => (u.FirstName != null && u.FirstName.ToLower().Contains(lowerSearch)) ||
                                         (u.LastName != null && u.LastName.ToLower().Contains(lowerSearch)) ||
                                         (u.Email != null && u.Email.ToLower().Contains(lowerSearch)));
            }

            var totalCount = await query.CountAsync();

            var users = await query
                .OrderBy(u => u.LastName)
                .ThenBy(u => u.FirstName)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(u => new ChatUserDto
                {
                    Id = u.Id,
                    FirstName = u.FirstName,
                    LastName = u.LastName,
                    Role = u.Role,
                    IsActive = u.IsActive,
                    Email = u.Email
                })
                .ToListAsync();

            return (users, totalCount);
        }

        public async Task<(IEnumerable<ChatMessageDto> Messages, int TotalCount)> GetMessagesAsync(
            Guid currentUserId,
            Guid otherUserId,
            int page,
            int pageSize)
        {
            var allowed = await IsChatAllowedAsync(currentUserId, otherUserId);
            if (!allowed)
            {
                throw new UnauthorizedAccessException("You are not authorized to chat with this user.");
            }

            var query = _context.Messages
                .Where(m => (m.SenderId == currentUserId && m.ReceiverId == otherUserId) ||
                            (m.SenderId == otherUserId && m.ReceiverId == currentUserId));

            var totalCount = await query.CountAsync();

            var messages = await query
                .OrderBy(m => m.SentAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(m => new ChatMessageDto
                {
                    Id = m.Id,
                    SenderId = m.SenderId,
                    ReceiverId = m.ReceiverId,
                    Content = m.Content,
                    SentAt = m.SentAt,
                    IsRead = m.IsRead
                })
                .ToListAsync();

            return (messages, totalCount);
        }

        public async Task<IEnumerable<ChatUserDto>> GetConversationsAsync(Guid currentUserId)
        {
            var senders = await _context.Messages
                .Where(m => m.ReceiverId == currentUserId)
                .Select(m => m.SenderId)
                .Distinct()
                .ToListAsync();

            var receivers = await _context.Messages
                .Where(m => m.SenderId == currentUserId)
                .Select(m => m.ReceiverId)
                .Distinct()
                .ToListAsync();

            var contactIds = senders.Concat(receivers).Distinct().ToList();

            var contacts = await _context.Users
                .Where(u => contactIds.Contains(u.Id))
                .Select(u => new ChatUserDto
                {
                    Id = u.Id,
                    FirstName = u.FirstName,
                    LastName = u.LastName,
                    Role = u.Role,
                    IsActive = u.IsActive,
                    Email = u.Email
                })
                .ToListAsync();

            return contacts;
        }

        public async Task<ChatMessageDto> SaveMessageAsync(Guid senderId, Guid receiverId, string content)
        {
            var allowed = await IsChatAllowedAsync(senderId, receiverId);
            if (!allowed)
            {
                throw new UnauthorizedAccessException("You are not authorized to send messages to this user.");
            }

            if (string.IsNullOrWhiteSpace(content))
            {
                throw new ArgumentException("Message content cannot be empty.");
            }

            var message = new Message
            {
                SenderId = senderId,
                ReceiverId = receiverId,
                Content = content,
                SentAt = DateTime.UtcNow,
                IsRead = false
            };

            _context.Messages.Add(message);
            await _context.SaveChangesAsync();

            return new ChatMessageDto
            {
                Id = message.Id,
                SenderId = message.SenderId,
                ReceiverId = message.ReceiverId,
                Content = message.Content,
                SentAt = message.SentAt,
                IsRead = message.IsRead
            };
        }

        public async Task<bool> IsChatAllowedAsync(Guid userAId, Guid userBId)
        {
            var userA = await _context.Users.FindAsync(userAId);
            var userB = await _context.Users.FindAsync(userBId);

            if (userA == null || userB == null) return false;
            if (!userA.IsActive || !userB.IsActive) return false;

            return CanInitiate(userA.Role, userB.Role) || CanInitiate(userB.Role, userA.Role);
        }

        private bool CanInitiate(string fromRole, string toRole)
        {
            if (fromRole == "Admin")
                return toRole == "Patient" || toRole == "Doctor" || toRole == "Nurse";
            if (fromRole == "Doctor")
                return toRole == "Nurse" || toRole == "Patient";
            if (fromRole == "Patient")
                return toRole == "Doctor";
            if (fromRole == "Nurse")
                return toRole == "Doctor" || toRole == "Patient";
            return false;
        }
    }
}
