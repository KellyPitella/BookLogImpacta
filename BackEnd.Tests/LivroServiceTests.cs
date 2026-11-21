using BookLog.Data;
using BookLog.DTOs;
using BookLog.Models;
using BookLog.Services;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace BookLog.Tests;

public class LivroServiceTests
{
    private static BookLogContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<BookLogContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        return new BookLogContext(options);
    }

    [Fact]
    public async Task CreateAndUpdatePersistStatusAndFavorite()
    {
        using var context = CreateContext();
        var service = new LivroService(context);
        var created = await service.CreateLivro(new CreateLivroDto
        {
            Titulo = "Livro", TotalPaginas = 100, Status = LivroStatus.Lido, Favorito = true
        }, 1);
        Assert.True(created.Favorito);
        Assert.True(created.Concluido);
        Assert.Equal(100, created.PaginasLidas);
        Assert.Equal(LivroStatus.Lido, created.Status);
        context.ChangeTracker.Clear();
        var stored = await service.GetLivrosPorUsuario(1, LivroStatus.Lido, true);
        Assert.Single(stored);
        Assert.Equal(created.Id, stored[0].Id);

        var updated = await service.UpdateLivro(created.Id, new UpdateLivroDto
        {
            Status = LivroStatus.QueroLer, Favorito = false
        }, 1);
        Assert.NotNull(updated);
        Assert.False(updated.Favorito);
        Assert.False(updated.Concluido);
        Assert.Equal(100, updated.PaginasLidas);
        Assert.Equal(LivroStatus.QueroLer, updated.Status);

        var edited = await service.UpdateLivro(created.Id, new UpdateLivroDto { Titulo = "Novo" }, 1);
        Assert.NotNull(edited);
        Assert.False(edited.Concluido);
        Assert.Equal(LivroStatus.QueroLer, edited.Status);
    }

    [Fact]
    public async Task FiltersAreCombinedAndScopedToTheCurrentUser()
    {
        using var context = CreateContext();
        var service = new LivroService(context);
        await service.CreateLivro(new CreateLivroDto { Titulo = "A", TotalPaginas = 50, Favorito = true }, 1);
        await service.CreateLivro(new CreateLivroDto { Titulo = "B", TotalPaginas = 50, Status = LivroStatus.Lendo }, 1);
        await service.CreateLivro(new CreateLivroDto { Titulo = "Outro", TotalPaginas = 50, Favorito = true }, 2);

        Assert.Equal(2, (await service.GetLivrosPorUsuario(1)).Count);
        Assert.Equal(2, (await service.GetLivrosPorUsuario(1, apenasFavoritos: false)).Count);
        var filtered = await service.GetLivrosPorUsuario(1, LivroStatus.QueroLer, true);
        Assert.Single(filtered);
        Assert.Equal("A", filtered[0].Titulo);
        Assert.Equal(LivroStatus.QueroLer, filtered[0].Status);
        Assert.True(filtered[0].Favorito);
        Assert.Empty(await service.GetLivrosPorUsuario(1, LivroStatus.Lendo, true));
        await Assert.ThrowsAsync<ArgumentException>(() => service.GetLivrosPorUsuario(1, "invalido"));
    }

    [Fact]
    public async Task ToggleAndStatusRespectOwnershipAndSynchronizeCompletion()
    {
        using var context = CreateContext();
        var service = new LivroService(context);
        var created = await service.CreateLivro(new CreateLivroDto { Titulo = "A", TotalPaginas = 50 }, 1);
        Assert.Null(await service.ToggleFavorito(created.Id, 2));
        Assert.Null(await service.UpdateStatus(created.Id, LivroStatus.Lido, 2));
        Assert.True((await service.ToggleFavorito(created.Id, 1))!.Favorito);
        context.ChangeTracker.Clear();
        Assert.Single(await service.GetLivrosPorUsuario(1, apenasFavoritos: true));
        Assert.False((await service.ToggleFavorito(created.Id, 1))!.Favorito);
        var read = await service.UpdateStatus(created.Id, LivroStatus.Lido, 1);
        Assert.NotNull(read);
        Assert.True(read.Concluido);
        Assert.Equal(50, read.PaginasLidas);
        var reading = await service.UpdateStatus(created.Id, LivroStatus.Lendo, 1);
        Assert.NotNull(reading);
        Assert.False(reading.Concluido);
        Assert.Equal(50, reading.PaginasLidas);
        Assert.Equal(LivroStatus.Lendo, reading.Status);
        await Assert.ThrowsAsync<ArgumentException>(() => service.UpdateStatus(created.Id, "LIDO", 1));
        Assert.Equal(LivroStatus.Lendo, context.Livros.Single().Status);
    }

    [Fact]
    public async Task ProgressUpdatesStatusAndTotalPageEditsRecalculateIt()
    {
        using var context = CreateContext();
        var books = new LivroService(context);
        var progress = new ProgressoService(context);
        var created = await books.CreateLivro(new CreateLivroDto { Titulo = "A", TotalPaginas = 50 }, 1);
        var dto = new CreateProgressoDto
        {
            LivroId = created.Id, PaginasLidas = 20, Data = DateTime.UtcNow
        };
        Assert.Null(await progress.Registrar(dto, 2));
        Assert.NotNull(await progress.Registrar(dto, 1));
        Assert.Equal(LivroStatus.Lendo, context.Livros.Single().Status);
        dto.PaginasLidas = 30;
        await progress.Registrar(dto, 1);
        Assert.True(context.Livros.Single().Concluido);
        Assert.Equal(LivroStatus.Lido, context.Livros.Single().Status);
        var edited = await books.UpdateLivro(created.Id, new UpdateLivroDto { TotalPaginas = 60 }, 1);
        Assert.NotNull(edited);
        Assert.False(edited.Concluido);
        Assert.Equal(LivroStatus.Lendo, edited.Status);
    }

    [Fact]
    public async Task InvalidStatusIsRejectedOnCreateAndUpdate()
    {
        using var context = CreateContext();
        var service = new LivroService(context);
        await Assert.ThrowsAsync<ArgumentException>(() => service.CreateLivro(
            new CreateLivroDto { Titulo = "A", TotalPaginas = 10, Status = "" }, 1));
        Assert.Empty(context.Livros);
        var created = await service.CreateLivro(new CreateLivroDto { Titulo = "A", TotalPaginas = 10 }, 1);
        await Assert.ThrowsAsync<ArgumentException>(() => service.UpdateLivro(
            created.Id, new UpdateLivroDto { Status = "outro" }, 1));
        Assert.Equal(LivroStatus.QueroLer, context.Livros.Single().Status);
    }
}
