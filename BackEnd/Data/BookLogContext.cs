using Microsoft.EntityFrameworkCore;
using BookLog.Models;

namespace BookLog.Data;

public class BookLogContext : DbContext
{
    public BookLogContext(DbContextOptions<BookLogContext> options)
        : base(options) { }

    public DbSet<Usuario> Usuarios { get; set; }

    public DbSet<Livro> Livros { get; set; }

    public DbSet<ProgressoLeitura> ProgressosLeitura { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Usuario>(entity =>
        {
            entity.HasIndex(e => e.Email)
                  .IsUnique();
        });

        modelBuilder.Entity<Livro>(entity =>
        {
            entity.HasOne(e => e.Usuario)
                  .WithMany(e => e.Livros)
                  .HasForeignKey(e => e.UsuarioId);

            entity.HasMany(e => e.Progressos)
                .WithOne(e => e.Livro)
                .HasForeignKey(e => e.LivroId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}