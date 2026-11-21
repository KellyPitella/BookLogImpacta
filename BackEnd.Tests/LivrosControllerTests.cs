using System.Security.Claims;
using BookLog.Controllers;
using BookLog.Data;
using BookLog.DTOs;
using BookLog.Models;
using BookLog.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace BookLog.Tests;

public class LivrosControllerTests
{
    [Fact]
    public async Task FiltersAndPatchActionsReturnExpectedResults()
    {
        var options = new DbContextOptionsBuilder<BookLogContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        using var context = new BookLogContext(options);
        var service = new LivroService(context);
        var book = await service.CreateLivro(new CreateLivroDto { Titulo = "A", TotalPaginas = 10 }, 1);
        var controller = new LivrosController(service)
        {
            ControllerContext = new ControllerContext
            {
                HttpContext = new DefaultHttpContext
                {
                    User = new ClaimsPrincipal(new ClaimsIdentity(
                        [new Claim(ClaimTypes.NameIdentifier, "1")], "test"))
                }
            }
        };

        var toggled = Assert.IsType<OkObjectResult>(await controller.ToggleFavorito(book.Id, default));
        Assert.True(Assert.IsType<LivroDto>(toggled.Value).Favorito);
        var updated = Assert.IsType<OkObjectResult>(await controller.UpdateStatus(
            book.Id, new UpdateLivroStatusDto { Status = LivroStatus.Lido }, default));
        var updatedBook = Assert.IsType<LivroDto>(updated.Value);
        Assert.Equal(LivroStatus.Lido, updatedBook.Status);
        Assert.True(updatedBook.Concluido);
        Assert.Equal(10, updatedBook.PaginasLidas);
        var filtered = Assert.IsType<OkObjectResult>(await controller.GetLivros(LivroStatus.Lido, true, default));
        Assert.Single(Assert.IsType<List<LivroDto>>(filtered.Value));
        Assert.IsType<BadRequestObjectResult>(await controller.GetLivros("invalido", null, default));
        Assert.IsType<BadRequestObjectResult>(await controller.UpdateStatus(
            book.Id, new UpdateLivroStatusDto { Status = "invalido" }, default));
        Assert.IsType<NotFoundResult>(await controller.ToggleFavorito(999, default));
        Assert.IsType<NotFoundResult>(await controller.UpdateStatus(
            999, new UpdateLivroStatusDto { Status = LivroStatus.Lendo }, default));
    }
}
